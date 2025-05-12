from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mail import Mail, Message
import requests
import base64
import os
from dotenv import load_dotenv
import random
import string

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Configure Flask-Mail
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv('EMAIL_USER')
app.config['MAIL_PASSWORD'] = os.getenv('EMAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('EMAIL_USER')

mail = Mail(app)

# Gemini API configuration
GEMINI_API_KEY = "AIzaSyA4w7tNP0XG822TJdD9rcN4RVsOO-HClyg"
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + GEMINI_API_KEY

def generate_reset_code():
    return ''.join(random.choices(string.digits, k=6))

@app.route('/classify', methods=['POST'])
def classify():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    image_file = request.files['image']
    image_bytes = image_file.read()
    image_b64 = base64.b64encode(image_bytes).decode('utf-8')

    data = {
        "contents": [{
            "parts": [
                {"text": "What food is in this image? Give me the food name and a short nutritional summary (calories, protein, fat, carbs, etc) if possible."},
                {
                    "inline_data": {
                        "mime_type": "image/jpeg",
                        "data": image_b64
                    }
                }
            ]
        }]
    }

    response = requests.post(GEMINI_API_URL, headers={'Content-Type': 'application/json'}, json=data)
    if response.status_code == 200:
        gemini_response = response.json()
        try:
            text = gemini_response['candidates'][0]['content']['parts'][0]['text']
        except Exception:
            text = str(gemini_response)
        return jsonify({'result': text, 'status': 'success'})
    else:
        return jsonify({'error': response.text, 'status': 'error'}), 500

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    question = data.get('question', '')
    if not question:
        return jsonify({'error': 'No question provided', 'status': 'error'}), 400

    data = {
        "contents": [{
            "parts": [
                {"text": question}
            ]
        }]
    }

    response = requests.post(GEMINI_API_URL, headers={'Content-Type': 'application/json'}, json=data)
    if response.status_code == 200:
        gemini_response = response.json()
        try:
            text = gemini_response['candidates'][0]['content']['parts'][0]['text']
        except Exception:
            text = str(gemini_response)
        return jsonify({'result': text, 'status': 'success'})
    else:
        return jsonify({'error': response.text, 'status': 'error'}), 500

@app.route('/auth/forgot-password', methods=['POST'])
def forgot_password():
    try:
        data = request.get_json()
        email = data.get('email')
        email_exists = data.get('email_exists', True)  # Flutter will verify if email exists
        
        if not email:
            return jsonify({'error': 'Email is required'}), 400

        if not email_exists:
            return jsonify({'error': 'Email not found'}), 404

        # Generate a 6-digit code
        reset_code = generate_reset_code()
        
        # Send email with reset code
        msg = Message(
            'Password Reset Code',
            recipients=[email]
        )
        msg.body = f'''
            Your password reset code is: {reset_code}
            
            Enter this code in the app to reset your password.
            
            If you did not request this, please ignore this email.
        '''
        
        mail.send(msg)
        return jsonify({
            'message': 'Reset code sent to your email',
            'code': reset_code  # Send code back to Flutter to store in database
        }), 200
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 