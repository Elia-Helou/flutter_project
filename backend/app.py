from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
from PIL import Image
import io
import os
import urllib.request

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load the model once at startup
print("Loading MobileNet model...")
model = hub.load("https://tfhub.dev/google/tf2-preview/mobilenet_v2/classification/4")
print("Model loaded successfully!")

# Load labels for ImageNet classes
LABELS_URL = "https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt"
LABELS_PATH = "ImageNetLabels.txt"

if not os.path.exists(LABELS_PATH):
    print("Downloading ImageNet labels...")
    urllib.request.urlretrieve(LABELS_URL, LABELS_PATH)
    print("Labels downloaded successfully!")

with open(LABELS_PATH, "r") as f:
    labels = [line.strip() for line in f.readlines()]

# Food-related ImageNet classes (subset of ImageNet that are food items)
FOOD_CLASSES = {
    'apple', 'banana', 'orange', 'strawberry', 'pineapple', 'pizza', 'hamburger',
    'hotdog', 'sandwich', 'ice cream', 'cake', 'cookie', 'bread', 'cheese',
    'pasta', 'rice', 'salad', 'soup', 'steak', 'chicken', 'fish', 'egg',
    'carrot', 'broccoli', 'corn', 'potato', 'tomato', 'cucumber', 'pepper',
    'mushroom', 'onion', 'garlic', 'lettuce', 'spinach', 'asparagus'
}

def preprocess_image(image_bytes):
    """Preprocess the image for the model."""
    try:
        # Convert bytes to image
        image = Image.open(io.BytesIO(image_bytes))
        
        # Convert to RGB if necessary
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Resize to model's expected size
        image = image.resize((224, 224))
        
        # Convert to numpy array and normalize
        img_array = np.array(image) / 255.0
        
        # Add batch dimension
        img_array = img_array[np.newaxis, ...]
        
        return img_array
    except Exception as e:
        raise Exception(f"Error preprocessing image: {str(e)}")

def get_food_name(predictions):
    """Get the most likely food name from predictions."""
    try:
        # Get top 5 predictions
        top_5_indices = np.argsort(predictions[0])[-5:][::-1]
        
        # First try to find a food class in top 5 predictions
        for idx in top_5_indices:
            predicted_label = labels[idx].lower()
            # Check if the predicted label is in our food classes
            for food_class in FOOD_CLASSES:
                if food_class in predicted_label:
                    return food_class
        
        # If no food class found, return the top prediction
        return labels[top_5_indices[0]].lower()
    except Exception as e:
        raise Exception(f"Error getting food name: {str(e)}")

@app.route('/classify', methods=['POST'])
def classify():
    try:
        # Check if image was uploaded
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400

        # Get the image file
        image_file = request.files['image']
        if not image_file:
            return jsonify({'error': 'Empty image file'}), 400

        # Read image bytes
        image_bytes = image_file.read()
        if not image_bytes:
            return jsonify({'error': 'Could not read image data'}), 400

        # Preprocess the image
        processed_image = preprocess_image(image_bytes)
        
        # Get predictions
        predictions = model(processed_image)
        
        # Get the food name
        food_name = get_food_name(predictions)
        
        return jsonify({
            'food_name': food_name,
            'status': 'success'
        })

    except Exception as e:
        print(f"Error processing request: {str(e)}")
        return jsonify({
            'error': str(e),
            'status': 'error'
        }), 500

if __name__ == '__main__':
    print("Starting Flask server...")
    app.run(host='0.0.0.0', port=5000, debug=True) 