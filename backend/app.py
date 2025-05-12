from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mail import Mail, Message
from itsdangerous import URLSafeTimedSerializer
import requests
import base64
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Email configuration
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv('EMAIL_USER')
app.config['MAIL_PASSWORD'] = os.getenv('EMAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('EMAIL_USER')
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-here')

mail = Mail(app)
serializer = URLSafeTimedSerializer(app.config['SECRET_KEY'])

# Gemini API configuration
GEMINI_API_KEY = "AIzaSyA4w7tNP0XG822TJdD9rcN4RVsOO-HClyg"
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + GEMINI_API_KEY

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

        # Generate token
        token = serializer.dumps(email, salt='password-reset-salt')
        
        # Create reset URL using deep link
        reset_url = f"healthapp://reset-password?token={token}"
        
        # Send email
        msg = Message(
            'Password Reset Request',
            recipients=[email]
        )
        msg.body = f'''To reset your password, visit the following link:
{reset_url}

If you did not make this request then simply ignore this email.

This link will expire in 1 hour.
'''
        mail.send(msg)
        
        return jsonify({
            'message': 'Password reset email sent',
            'status': 'success'
        })
        
    except Exception as e:
        print(f"Error in forgot password: {str(e)}")
        return jsonify({
            'error': str(e),
            'status': 'error'
        }), 500

@app.route('/auth/verify-token', methods=['POST'])
def verify_token():
    try:
        data = request.get_json()
        token = data.get('token')
        
        if not token:
            return jsonify({'error': 'Token is required'}), 400
            
        # Verify token and get email
        try:
            email = serializer.loads(token, salt='password-reset-salt', max_age=3600)  # Token expires in 1 hour
            return jsonify({
                'email': email,
                'status': 'success'
            })
        except:
            return jsonify({'error': 'Invalid or expired token'}), 400
            
    except Exception as e:
        print(f"Error in verify token: {str(e)}")
        return jsonify({
            'error': str(e),
            'status': 'error'
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 