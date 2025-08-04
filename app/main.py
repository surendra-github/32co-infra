import os
import sys
import boto3
import logging
import uuid
from typing import List, Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="32co Application", version="1.0.0")

class Item(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    category: Optional[str] = None

class ItemCreate(BaseModel):
    name: str
    description: Optional[str] = None
    category: Optional[str] = None

@app.get("/")
async def root():
    return {
        "message": "Welcome to 32co Application", 
        "status": "running",
        "environment": os.environ.get('PYTHON_ENV', 'unknown'),
        "external_api_configured": bool(os.environ.get('EXTERNAL_API_KEY'))
    }

@app.get("/health")
async def health_check():
    try:
        dynamodb = boto3.resource('dynamodb')
        table_name = os.environ.get('DYNAMODB_TABLE')
        if table_name:
            table = dynamodb.Table(table_name)
            table.load()
        
        # Check if external API key is available
        external_api_key = os.environ.get('EXTERNAL_API_KEY')
        
        return {
            "status": "healthy", 
            "dynamodb": "connected",
            "secrets_loaded": bool(external_api_key),
            "environment": os.environ.get('PYTHON_ENV', 'unknown')
        }
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        raise HTTPException(status_code=503, detail="Service unhealthy")

@app.get("/items", response_model=List[Item])
async def get_items():
    try:
        dynamodb = boto3.resource('dynamodb')
        table_name = os.environ.get('DYNAMODB_TABLE')
        table = dynamodb.Table(table_name)
        
        response = table.scan()
        items = response.get('Items', [])
        
        return [Item(**item) for item in items]
    except ClientError as e:
        logger.error(f"DynamoDB error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve items")

@app.post("/items", response_model=Item)
async def create_item(item: ItemCreate):
    try:
        item_id = str(uuid.uuid4())
        
        dynamodb = boto3.resource('dynamodb')
        table_name = os.environ.get('DYNAMODB_TABLE')
        table = dynamodb.Table(table_name)
        
        item_data = {
            'id': item_id,
            'name': item.name,
            'description': item.description,
            'category': item.category
        }
        
        table.put_item(Item=item_data)
        
        return Item(**item_data)
    except ClientError as e:
        logger.error(f"DynamoDB error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to create item")

@app.get("/items/{item_id}", response_model=Item)
async def get_item(item_id: str):
    try:
        dynamodb = boto3.resource('dynamodb')
        table_name = os.environ.get('DYNAMODB_TABLE')
        table = dynamodb.Table(table_name)
        
        response = table.get_item(Key={'id': item_id})
        
        if 'Item' not in response:
            raise HTTPException(status_code=404, detail="Item not found")
        
        return Item(**response['Item'])
    except ClientError as e:
        logger.error(f"DynamoDB error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve item")

# New endpoint to demonstrate external API integration
@app.get("/external-api-status")
async def external_api_status():
    """Endpoint to show external API key is available"""
    external_api_key = os.environ.get('EXTERNAL_API_KEY')
    
    if not external_api_key:
        raise HTTPException(status_code=503, detail="External API key not configured")
    
    # In a real app, you'd use this key to call an external service
    return {
        "status": "External API key is configured",
        "key_length": len(external_api_key),
        "key_prefix": external_api_key[:4] + "***" if len(external_api_key) > 4 else "***"
    }

if __name__ == "__main__":
    import uvicorn
    import os
    host = os.environ.get("UVICORN_HOST", "127.0.0.1")
    port = int(os.environ.get("UVICORN_PORT", "8000"))
    uvicorn.run(app, host=host, port=port)