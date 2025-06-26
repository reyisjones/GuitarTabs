#!/usr/bin/env python
"""
Test script for the Guitar Tabs backend.
This script tests the basic functionality of the Flask API.
"""

import os
import sys
import requests
import json
from time import sleep

BASE_URL = "http://localhost:5000"

def test_health_check():
    """Test the health check endpoint."""
    print("Testing health check endpoint...")
    response = requests.get(f"{BASE_URL}/api/health")
    if response.status_code == 200:
        print("✅ Health check successful")
        return True
    else:
        print(f"❌ Health check failed with status code {response.status_code}")
        return False

def test_empty_tabs_list():
    """Test the tabs list endpoint when empty."""
    print("Testing empty tabs list...")
    response = requests.get(f"{BASE_URL}/api/tabs")
    if response.status_code == 200:
        data = response.json()
        if 'tabs' in data and isinstance(data['tabs'], list):
            print(f"✅ Tabs list endpoint working (found {len(data['tabs'])} tabs)")
            return True
        else:
            print("❌ Tabs list has incorrect format")
            return False
    else:
        print(f"❌ Tabs list request failed with status code {response.status_code}")
        return False

def test_upload_tab():
    """Test uploading a tab file."""
    print("Testing file upload...")
    
    # Create a dummy file for testing
    test_file_path = "test_tab.gp5"
    with open(test_file_path, "w") as f:
        f.write("This is a test file to simulate a Guitar Pro file")
    
    try:
        with open(test_file_path, "rb") as f:
            response = requests.post(
                f"{BASE_URL}/api/tabs",
                files={"file": (test_file_path, f)}
            )
        
        if response.status_code == 201:
            data = response.json()
            file_id = data.get('id')
            print(f"✅ File upload successful (ID: {file_id})")
            return file_id
        else:
            print(f"❌ File upload failed with status code {response.status_code}")
            return None
    finally:
        # Clean up the test file
        if os.path.exists(test_file_path):
            os.remove(test_file_path)

def test_get_tab(file_id):
    """Test getting a tab file by ID."""
    if not file_id:
        print("❌ Skipping get tab test (no file ID)")
        return False
    
    print(f"Testing file retrieval for ID: {file_id}...")
    response = requests.get(f"{BASE_URL}/api/tabs/{file_id}")
    
    if response.status_code == 200:
        print("✅ File retrieval successful")
        return True
    else:
        print(f"❌ File retrieval failed with status code {response.status_code}")
        return False

def test_delete_tab(file_id):
    """Test deleting a tab file by ID."""
    if not file_id:
        print("❌ Skipping delete tab test (no file ID)")
        return False
    
    print(f"Testing file deletion for ID: {file_id}...")
    response = requests.delete(f"{BASE_URL}/api/tabs/{file_id}")
    
    if response.status_code == 200:
        print("✅ File deletion successful")
        return True
    else:
        print(f"❌ File deletion failed with status code {response.status_code}")
        return False

def main():
    """Main test function."""
    print("🎸 Starting Guitar Tabs backend tests...\n")
    
    # Check if the server is running
    if not test_health_check():
        print("\n❌ Server doesn't appear to be running. Please start the server and try again.")
        sys.exit(1)
    
    # Run the tests
    test_empty_tabs_list()
    file_id = test_upload_tab()
    
    if file_id:
        # Give the server a moment to process the upload
        sleep(1)
        test_get_tab(file_id)
        test_delete_tab(file_id)
    
    print("\n🎉 All tests completed!")

if __name__ == "__main__":
    main()
