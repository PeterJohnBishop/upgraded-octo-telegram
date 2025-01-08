import express from 'express';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, DeleteCommand, ScanCommand } from '@aws-sdk/lib-dynamodb';
import dotenv from 'dotenv';

const router = express.Router();
dotenv.config();

const dynamoDbClient = new DynamoDBClient({
    region: 'us-east-1',
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    },
});
const ddbDocClient = DynamoDBDocumentClient.from(dynamoDbClient);

// DynamoDB Table Name
const TABLE_NAME = process.env.AWS_DYNAMODB_TABLE_NAME;

// Create - Add a new item
router.post('/item', async (req, res) => {
    const { id, name, description } = req.body;

    const params = {
        TableName: TABLE_NAME,
        Item: { id, name, description }, // Replace with your actual schema
    };

    try {
        await ddbDocClient.send(new PutCommand(params));nbb    
        res.status(201).json({ message: 'Item created successfully', item: params.Item });
    } catch (error) {
        console.error('Error creating item:', error);
        res.status(500).json({ error: 'Error creating item' });
    }
});

// Read - Get a single item by ID
router.get('/item/:id', async (req, res) => {
    const { id } = req.params;

    const params = {
        TableName: TABLE_NAME,
        Key: { id },
    };

    try {
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        if (!Item) {
            return res.status(404).json({ error: 'Item not found' });
        }
        res.status(200).json(Item);
    } catch (error) {
        console.error('Error fetching item:', error);
        res.status(500).json({ error: 'Error fetching item' });
    }
});

// List - Get all items
router.get('/items', async (req, res) => {
    const params = {
        TableName: TABLE_NAME,
    };

    try {
        const { Items } = await ddbDocClient.send(new ScanCommand(params));
        res.status(200).json(Items);
    } catch (error) {
        console.error('Error fetching items:', error);
        res.status(500).json({ error: 'Error fetching items' });
    }
});

// Update - Modify an existing item
router.put('/item/:id', async (req, res) => {
    const { id } = req.params;
    const { name, description } = req.body;

    const params = {
        TableName: TABLE_NAME,
        Key: { id },
        UpdateExpression: 'set #name = :name, #description = :description',
        ExpressionAttributeNames: {
            '#name': 'name',
            '#description': 'description',
        },
        ExpressionAttributeValues: {
            ':name': name,
            ':description': description,
        },
        ReturnValues: 'ALL_NEW',
    };

    try {
        const { Attributes } = await ddbDocClient.send(new UpdateCommand(params));
        res.status(200).json({ message: 'Item updated successfully', updatedItem: Attributes });
    } catch (error) {
        console.error('Error updating item:', error);
        res.status(500).json({ error: 'Error updating item' });
    }
});

// Delete - Remove an item by ID
router.delete('/item/:id', async (req, res) => {
    const { id } = req.params;

    const params = {
        TableName: TABLE_NAME,
        Key: { id },
    };

    try {
        await ddbDocClient.send(new DeleteCommand(params));
        res.status(200).json({ message: 'Item deleted successfully' });
    } catch (error) {
        console.error('Error deleting item:', error);
        res.status(500).json({ error: 'Error deleting item' });
    }
});

export default router;