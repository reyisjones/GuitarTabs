from flask import Flask, jsonify, request, send_file
from flask_cors import CORS
from flask_socketio import SocketIO, emit
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
import os
from dotenv import load_dotenv
from werkzeug.utils import secure_filename
import uuid
import datetime

# Import user model
from models.users import UserRepository

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev_secret_key')
app.config['UPLOAD_FOLDER'] = os.getenv('UPLOAD_FOLDER', 'uploads')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max upload size
app.config['ALLOWED_EXTENSIONS'] = {'gp', 'gpx', 'gp5', 'musicxml'}

# Configure JWT
app.config["JWT_SECRET_KEY"] = os.getenv('JWT_SECRET_KEY', app.config['SECRET_KEY'])
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = datetime.timedelta(hours=24)
jwt = JWTManager(app)

# Enable CORS
CORS(app)

# Initialize SocketIO
socketio = SocketIO(app, cors_allowed_origins="*")

# Ensure upload directory exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']

# Routes
@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.datetime.now().isoformat()})

@app.route('/api/tabs', methods=['GET'])
@jwt_required(optional=True)
def get_tabs():
    try:
        files = []
        for filename in os.listdir(app.config['UPLOAD_FOLDER']):
            if allowed_file(filename):
                file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
                files.append({
                    'id': filename.split('.')[0],
                    'filename': filename,
                    'date_added': datetime.datetime.fromtimestamp(
                        os.path.getctime(file_path)
                    ).isoformat(),
                    'size': os.path.getsize(file_path)
                })
        return jsonify({'tabs': files})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/tabs/<tab_id>', methods=['GET'])
def get_tab(tab_id):
    try:
        for filename in os.listdir(app.config['UPLOAD_FOLDER']):
            if filename.startswith(tab_id + '.'):
                return send_file(
                    os.path.join(app.config['UPLOAD_FOLDER'], filename),
                    as_attachment=True,
                    download_name=filename
                )
        return jsonify({'error': 'Tab not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/tabs', methods=['POST'])
@jwt_required()
def upload_tab():
    # Get the current user ID from the JWT token
    current_user_id = get_jwt_identity()
    
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_id = str(uuid.uuid4())
        extension = filename.rsplit('.', 1)[1].lower()
        new_filename = f"{file_id}.{extension}"
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], new_filename)
        file.save(file_path)
        
        return jsonify({
            'id': file_id,
            'filename': filename,
            'stored_as': new_filename,
            'date_added': datetime.datetime.now().isoformat(),
            'size': os.path.getsize(file_path),
            'uploaded_by': current_user_id
        }), 201
    
    return jsonify({'error': 'File type not allowed'}), 400

@app.route('/api/tabs/<tab_id>', methods=['DELETE'])
@jwt_required()
def delete_tab(tab_id):
    try:
        # Get the current user ID from the JWT token
        current_user_id = get_jwt_identity()
        
        deleted = False        
        for filename in os.listdir(app.config['UPLOAD_FOLDER']):
            if filename.startswith(tab_id + '.'):
                os.remove(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                deleted = True
                break
        if deleted:
            return jsonify({'message': 'Tab deleted successfully'}), 200
        else:
            return jsonify({'error': 'Tab not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Authentication routes
@app.route('/api/auth/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        
        if not data or not data.get('username') or not data.get('password'):
            return jsonify({'error': 'Username and password are required'}), 400
        
        success, result = UserRepository.create_user(
            username=data.get('username'),
            password=data.get('password'),
            email=data.get('email')
        )
        
        if not success:
            return jsonify({'error': result}), 400
        
        # Create access token for the new user
        access_token = create_access_token(identity=result.user_id)
        
        return jsonify({
            'message': 'User registered successfully',
            'user_id': result.user_id,
            'username': result.username,
            'access_token': access_token
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        if not data or not data.get('username') or not data.get('password'):
            return jsonify({'error': 'Username and password are required'}), 400
        
        user = UserRepository.get_user_by_username(data.get('username'))
        
        if not user or not user.check_password(data.get('password')):
            return jsonify({'error': 'Invalid username or password'}), 401
        
        # Create access token
        access_token = create_access_token(identity=user.user_id)
        
        return jsonify({
            'user_id': user.user_id,
            'username': user.username,
            'access_token': access_token
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/auth/user', methods=['GET'])
@jwt_required()
def get_user_profile():
    try:
        user_id = get_jwt_identity()
        user = UserRepository.get_user_by_id(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        return jsonify({
            'user_id': user.user_id,
            'username': user.username,
            'email': user.email,
            'created_at': user.created_at
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/auth/user', methods=['PUT'])
@jwt_required()
def update_user_profile():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        success, result = UserRepository.update_user(user_id, data)
        
        if not success:
            return jsonify({'error': result}), 400
        
        return jsonify({
            'message': 'User updated successfully',
            'user_id': result.user_id,
            'username': result.username,
            'email': result.email,
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# WebSocket for Karaoke Tab Mode
@socketio.on('connect')
def handle_connect():
    print('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

@socketio.on('sync_playback')
def handle_sync_playback(data):
    # Broadcast playback position to all clients
    emit('playback_position', data, broadcast=True)

# Create a test user for easy application testing
def create_test_user():
    try:
        # Check if test user already exists
        test_user = UserRepository.get_user_by_username('testuser')
        if test_user:
            print("Test user already exists. Username: testuser, Password: password123")
            return
        
        # Create test user if it doesn't exist
        success, result = UserRepository.create_user(
            username='testuser',
            password='password123',
            email='test@example.com'
        )
        
        if success:
            print("Test user created successfully. Username: testuser, Password: password123")
        else:
            print(f"Failed to create test user: {result}")
    except Exception as e:
        print(f"Error creating test user: {str(e)}")

# Create test user on application start - using modern Flask pattern
# In Flask 2.0+, before_first_request was removed
# Instead, we use the app factory pattern with a function
with app.app_context():
    create_test_user()

# Make sure to clear out any cached .pyc files if you encounter issues
# This can be done by deleting the __pycache__ folder before starting the app

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=int(os.getenv('PORT', 5000)), debug=True)
