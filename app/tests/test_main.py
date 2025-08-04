import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
import os
import sys

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Set test environment variables
os.environ.update({
    'DYNAMODB_TABLE': 'test-table',
    'PYTHON_ENV': 'test',
    'EXTERNAL_API_KEY': 'test-key'
})

from main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    data = response.json()
    assert response.status_code == 200  # nosec
    assert "Welcome to 32co Application" in data["message"]  # nosec
    assert data["status"] == "running"  # nosec

@patch('boto3.resource')
def test_health_check(mock_boto3):
    # Mock DynamoDB
    mock_table = MagicMock()
    mock_table.load.return_value = None
    mock_dynamodb = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_boto3.return_value = mock_dynamodb
    
    response = client.get("/health")
    data = response.json()
    assert response.status_code == 200  # nosec
    assert data["status"] == "healthy"  # nosec
    assert data["dynamodb"] == "connected"  # nosec

@patch('boto3.resource')
def test_get_items(mock_boto3):
    # Mock DynamoDB response
    mock_table = MagicMock()
    mock_table.scan.return_value = {
        'Items': [
            {'id': '1', 'name': 'Test Item', 'description': 'Test Description', 'category': 'test'}
        ]
    }
    mock_dynamodb = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_boto3.return_value = mock_dynamodb
    
    response = client.get("/items")
    items = response.json()
    assert response.status_code == 200  # nosec
    assert len(items) == 1  # nosec
    assert items[0]["name"] == "Test Item"  # nosec

@patch('boto3.resource')
@patch('uuid.uuid4')
def test_create_item(mock_uuid, mock_boto3):
    # Mock UUID generation
    mock_uuid.return_value = '12345678-1234-5678-1234-567812345678'
    
    # Mock DynamoDB
    mock_table = MagicMock()
    mock_table.put_item.return_value = {}
    mock_dynamodb = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_boto3.return_value = mock_dynamodb
    
    test_item = {
        "name": "New Item",
        "description": "New Description",
        "category": "Test Category"
    }
    
    response = client.post("/items", json=test_item)
    data = response.json()
    assert response.status_code == 200  # nosec
    assert data["name"] == "New Item"  # nosec
    assert "id" in data  # nosec

def test_external_api_status():
    response = client.get("/external-api-status")
    data = response.json()
    assert response.status_code == 200  # nosec
    assert "External API key is configured" in data["status"]  # nosec
    assert data["key_length"] > 0  # nosec

@patch('boto3.resource')
def test_get_item_not_found(mock_boto3):
    # Mock DynamoDB response for non-existent item
    mock_table = MagicMock()
    mock_table.get_item.return_value = {}
    mock_dynamodb = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_boto3.return_value = mock_dynamodb
    
    response = client.get("/items/nonexistent")
    assert response.status_code == 404  # nosec
    assert response.json()["detail"] == "Item not found"  # nosec