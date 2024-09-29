from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
import bcrypt
import requests
import base64
from google.cloud import vision
import os

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "rampage_sa_key.json"

app = Flask(__name__)

# Initialize Firebase
cred = credentials.Certificate('firebase_config.json')  # Firebase Admin SDK
firebase_admin.initialize_app(cred)

db = firestore.client()  # Firestore database client

# Initialize Google Cloud Vision API client
vision_client = vision.ImageAnnotatorClient()

@app.route('/')
def home():
    return "Firebase and Vision API connected successfully!"

# User Sign-up Route
@app.route('/signup', methods=['POST'])
def signup():
    data = request.json

    if not data or not data.get('email') or not data.get('password') or not data.get('username'):
        return jsonify({"error": "Missing fields"}), 400

    email = data.get('email')
    username = data.get('username')
    password = data.get('password')

    # Hash the password
    password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    # Add user to Firestore
    user_ref = db.collection('users').document(email)
    user_ref.set({
        'username': username,
        'email': email,
        'password': password_hash.decode('utf-8')  # Store the hashed password
    })

    return jsonify({"message": "User signed up successfully"}), 201

# Geocoding helper function to get GeoPoint from address
def get_geopoint_from_address(address):
    geocoding_api_url = 'https://maps.googleapis.com/maps/api/geocode/json'
    params = {
        'address': address,
        'key': 'AIzaSyDZLA18UIIYCfskesT99a-xt0yht2SY-0w'
    }
    response = requests.get(geocoding_api_url, params=params)
    if response.status_code == 200:
        data = response.json()
        if data['results']:
            location = data['results'][0]['geometry']['location']
            return location['lat'], location['lng']
    return None, None

# Vision API Image Processing
def analyze_image(image_data):
    """Analyze image using Google Vision API to extract labels."""
    image = vision.Image(content=image_data)
    response = vision_client.label_detection(image=image)
    labels = response.label_annotations

    if response.error.message:
        raise Exception(f"Error with Vision API: {response.error.message}")

    # Extract label descriptions and return them
    return [label.description for label in labels]

# Place Upload Route (for adding places with image processing)
@app.route('/save-place', methods=['POST'])
def save_place():
    data = request.json
    name = data.get('name')
    address = data.get('address')
    selected_features = data.get('features')
    image_base64 = data.get('image')  # Expecting base64 encoded image

    # Validate required fields
    if not name or not address or not selected_features or not image_base64:
        return jsonify({"error": "Missing fields"}), 400

    # Decode the base64 image
    try:
        image_data = base64.b64decode(image_base64)
    except Exception as e:
        return jsonify({"error": "Invalid image data"}), 400

    # Process the image with the Vision API
    try:
        detected_features = analyze_image(image_data)
        print("Detected Features:", detected_features)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    # Normalize both selected and detected features for comparison
    selected_features_normalized = [feature.strip().lower() for feature in selected_features]
    detected_features_normalized = [feature.strip().lower() for feature in detected_features]

    # Check for partial matches
    if all(any(selected_feature in detected_feature for detected_feature in detected_features_normalized)
           for selected_feature in selected_features_normalized):
        # Get GeoPoint from address
        latitude, longitude = get_geopoint_from_address(address)
        if latitude and longitude:
            # Create a document ID based on lat_lon
            lat_lon = f"{latitude}_{longitude}"

            # Check if a place with this ID already exists
            place_ref = db.collection('places').document(lat_lon)
            place = place_ref.get()

            if place.exists:
                # If the place exists, merge new features with the existing ones
                existing_data = place.to_dict()
                existing_features = set(existing_data.get('features', '').split(','))
                new_features = set(selected_features_normalized)

                # Merge the features (remove duplicates)
                updated_features = existing_features.union(new_features)

                # Update the existing place with the merged features
                place_ref.update({
                    'features': ','.join(updated_features)
                })
                return jsonify(
                    {"message": "Place updated successfully",
                     "merged_features": list(updated_features),
                     "detected_features": detected_features}), 200
            else:
                # If the place doesn't exist, create a new document with the lat_lon ID
                place_ref.set({
                    'name': name,
                    'address': address,
                    'location': firestore.GeoPoint(latitude, longitude),
                    'features': ','.join(selected_features_normalized)
                })
                return jsonify({
                    "message": "Place added successfully",
                    "detected_features": detected_features,
                    "selected_features": selected_features
                }), 200
        else:
            return jsonify({"error": "Unable to get GeoPoint from address"}), 400
    else:
        return jsonify({
            "error": "Not all features matched the image analysis",
            "detected_features": detected_features,
            "selected_features": selected_features
        }), 400


# Get Places Route (retrieves nearby places with specific features)
@app.route('/places', methods=['GET'])
def get_places():
    try:
        # feature = request.args.get('feature')  # Fetch the feature being queried
        data = request.json
        requested_features_str = str(data.get('features'))
        if not requested_features_str.strip():
            return jsonify({"error": "No feature(s) provided"}), 400

        requested_features_arr = [feature.strip() for feature in requested_features_str.split(',')]
        print("Fetch Places for following features: ", requested_features_arr)

        # Query Firestore for places that have the feature in their features string
        places_ref = db.collection('places')
        places = []

        query = places_ref #.where('features', '>=', feature).where('features', '<=', feature + '\uf8ff')
        results = query.stream()
        for place in results:
            place_data = place.to_dict()
            feature_db = place_data['features'].split(',')
            features_present = []
            for feature in requested_features_arr:
                if feature in feature_db:
                    features_present.append(feature)
            if not features_present:
                continue
            print("Feature(s) Found: ", features_present)
            # Convert GeoPoint to a dictionary with latitude and longitude
            location = place_data['location']
            if isinstance(location, firestore.GeoPoint):
                location = {'latitude': location.latitude, 'longitude': location.longitude}

            places.append({
                'name': place_data['name'],
                'address': place_data['address'],
                'location': location,
                'features': features_present
            })

        return jsonify({"status": "success", "data": places}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/all-places', methods=['GET'])
def get_all_places():
    try:
        # Query Firestore for places that have the feature in their features string
        places_ref = db.collection('places')
        places = []
        query = places_ref #.where('features', '>=', feature).where('features', '<=', feature + '\uf8ff')
        results = query.stream()
        for place in results:
            place_data = place.to_dict()
            feature_db = place_data['features'].split(',')
            # Convert GeoPoint to a dictionary with latitude and longitude
            location = place_data['location']
            if isinstance(location, firestore.GeoPoint):
                location = {'latitude': location.latitude, 'longitude': location.longitude}

            places.append({
                'name': place_data['name'],
                'address': place_data['address'],
                'location': location,
                'features': feature_db
            })

        return jsonify({"status": "success", "data": places}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# Get User Route
@app.route('/user', methods=['GET'])
def get_user():
    email = request.args.get('email')  # Fetch email from query parameters

    if not email:
        return jsonify({"error": "Email is required"}), 400

    # Fetch the user document from Firestore
    user_ref = db.collection('users').document(email)
    user = user_ref.get()

    if user.exists:
        return jsonify(user.to_dict()), 200
    else:
        return jsonify({"error": "User not found"}), 404


if __name__ == "__main__":
    app.run(debug=True)