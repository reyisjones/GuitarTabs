import pytest
import json
import os
import tempfile
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['UPLOAD_FOLDER'] = tempfile.mkdtemp()
    
    with app.test_client() as client:
        yield client

def test_health_check(client):
    response = client.get('/api/health')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'healthy'
    assert 'timestamp' in data

def test_get_tabs_empty(client):
    response = client.get('/api/tabs')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'tabs' in data
    assert len(data['tabs']) == 0

def test_upload_invalid_file(client):
    response = client.post('/api/tabs', data={
        'file': (tempfile.NamedTemporaryFile(suffix='.txt'), 'test.txt')
    })
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data
    assert data['error'] == 'File type not allowed'

def test_upload_missing_file(client):
    response = client.post('/api/tabs')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data
    assert data['error'] == 'No file part'
