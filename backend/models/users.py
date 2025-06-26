import bcrypt
import uuid
import json
import os
from datetime import datetime

# Simple file-based storage for users
USERS_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'users.json')

# Ensure data directory exists
os.makedirs(os.path.dirname(USERS_FILE), exist_ok=True)

class User:
    def __init__(self, username, password=None, email=None, user_id=None, created_at=None):
        self.user_id = user_id or str(uuid.uuid4())
        self.username = username
        self.email = email
        self.password_hash = None
        self.created_at = created_at or datetime.now().isoformat()
        
        # Only hash password if it's provided (not already hashed)
        if password:
            self.set_password(password)
    
    def set_password(self, password):
        """Hash the password using bcrypt"""
        self.password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    def check_password(self, password):
        """Verify the password against the stored hash"""
        if not self.password_hash:
            return False
        return bcrypt.checkpw(password.encode('utf-8'), self.password_hash.encode('utf-8'))
    
    def to_dict(self):
        """Convert user to dictionary for JSON serialization"""
        return {
            'user_id': self.user_id,
            'username': self.username,
            'email': self.email,
            'password_hash': self.password_hash,
            'created_at': self.created_at
        }
    
    @classmethod
    def from_dict(cls, data):
        """Create user from dictionary"""
        user = cls(
            username=data['username'],
            email=data.get('email'),
            user_id=data['user_id'],
            created_at=data['created_at']
        )
        user.password_hash = data['password_hash']
        return user


class UserRepository:
    """Simple file-based user repository"""
    
    @staticmethod
    def _load_users():
        """Load users from JSON file"""
        if not os.path.exists(USERS_FILE):
            return {}
        
        try:
            with open(USERS_FILE, 'r') as f:
                users_data = json.load(f)
                return {user_id: User.from_dict(data) for user_id, data in users_data.items()}
        except (json.JSONDecodeError, FileNotFoundError):
            return {}
    
    @staticmethod
    def _save_users(users):
        """Save users to JSON file"""
        users_data = {user.user_id: user.to_dict() for user in users.values()}
        
        with open(USERS_FILE, 'w') as f:
            json.dump(users_data, f, indent=2)
    
    @classmethod
    def get_user_by_id(cls, user_id):
        """Get user by ID"""
        users = cls._load_users()
        return users.get(user_id)
    
    @classmethod
    def get_user_by_username(cls, username):
        """Get user by username"""
        users = cls._load_users()
        for user in users.values():
            if user.username.lower() == username.lower():
                return user
        return None
    
    @classmethod
    def create_user(cls, username, password, email=None):
        """Create a new user"""
        # Check if username already exists
        if cls.get_user_by_username(username):
            return False, "Username already exists"
        
        # Create new user
        user = User(username=username, password=password, email=email)
        
        # Save user
        users = cls._load_users()
        users[user.user_id] = user
        cls._save_users(users)
        
        return True, user
    
    @classmethod
    def update_user(cls, user_id, data):
        """Update user details"""
        users = cls._load_users()
        user = users.get(user_id)
        
        if not user:
            return False, "User not found"
        
        # Update fields
        if 'username' in data and data['username'] != user.username:
            # Check if new username exists
            existing = cls.get_user_by_username(data['username'])
            if existing and existing.user_id != user_id:
                return False, "Username already taken"
            user.username = data['username']
        
        if 'email' in data:
            user.email = data['email']
        
        if 'password' in data:
            user.set_password(data['password'])
        
        # Save updated users
        cls._save_users(users)
        return True, user
    
    @classmethod
    def delete_user(cls, user_id):
        """Delete a user"""
        users = cls._load_users()
        
        if user_id not in users:
            return False
        
        del users[user_id]
        cls._save_users(users)
        return True
