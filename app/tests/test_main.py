import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
import os

# Set test environment variables
os.environ.update({
    'DYNAMODB_TABLE': 'test-table',
    'DB_HOST': 'localhost',
    'DB_NAME': 'testdb',
    'DB_USER': 'testuser',
    'DB_PASSWORD': 'testpass'
})

from main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "Welcome to 32co Application" in response.json()["message"]

@patch('main.get_db_connection')
@patch('boto3.resource')
def test_health_check(mock_boto3, mock_db):
    # Mock database connection
    mock_conn = MagicMock()
    mock_db.return_value = mock_conn
    
    # Mock DynamoDB
    mock_table = MagicMock()
    mock_dynamodb = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_boto3.return_value = mock_dynamodb
    
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

@patch('boto3.resource')
def test_get_items(mock_boto3):
    # Mock DynamoDB response
    mock_table = MagicMock()
    mock_table.scan.return_value = {
        'Items': [
            {'id': '1', 'name': 'Test Item', 'description': 'Test Description'}
        ]
    }
    mock_dynamodb = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_boto3.return_value = mock_dynamodb
    
    response = client.get("/items")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["name"] == "Test Item"

@patch('boto3.resource')
@patch('uuid.uuid4')
def test_create_item(mock_uuid, mock_boto3):
    # Mock UUID generation
    mock_uuid.return_value.hex = 'test-uuid-1234'
    
    # Mock DynamoDB
    mock_table = MagicMock()
    mock_dynamodb = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_boto3.return_value = mock_dynamodb
    
    test_item = {
        "name": "New Item",
        "description": "New Description",
        "category": "Test Category"
    }
    
    response = client.post("/items", json=test_item)
    assert response.status_code == 200
    assert response.json()["name"] == "New Item"
    assert "id" in response.json()