import express from 'express';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, DeleteCommand, ScanCommand } from '@aws-sdk/lib-dynamodb';
import dotenv from 'dotenv';
import authenticateToken from '../middleware/jwtVerify.js';
import crypto from 'crypto';

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
const TABLE_NAME = process.env.USERS_AWS_DYNAMODB_TABLE_NAME;

function hashString(string) {
    // Normalize the email: lowercase and trim whitespace
    const normalizedString = string.toLowerCase().trim();
    // Create a SHA-256 hash of the normalized email
    const hash = crypto.createHash('sha256').update(normalizedString).digest('hex');

    return hash;
}

// Product: {
//     id: string; <-- hashString(name)
//     name: string;
//     description: string;
//     price: number;
//     quantity: number;
//     imageURL: string;
//     inventory: string;
// }

// Create New Product
router.post('/prod', authenticateToken, async (req, res) => {
    const { name, description, price, quantity, imageURL, inventory } = req.body;
    const id = hashString(name);
    try {
        const params = {
            TableName: TABLE_NAME,
            Item: { id, name, description, price, quantity, imageURL, inventory }, 
        };
        await ddbDocClient.send(new PutCommand(params));
        res.status(201).json({ message: 'Product created successfully', item: params.Item });
    } catch (error) {
        console.error('Error creating user:', error);
        res.status(500).json({ error: 'Error creating product', errorMessage: error.message });
    }
});

// Find Product by ID
router.get('/prod/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        if (!Item) {
            return res.status(404).json({ error: 'Product not found' });
        }
        res.status(200).json(Item);
    } catch (error) {
        console.error('Error fetching product:', error);
        res.status(500).json({ error: 'Error fetching product', errorMessage: error.message });
    }
});

// List All Products
router.get('/', authenticateToken, async (req, res) => {
    const params = {
        TableName: TABLE_NAME,
    };
    try {
        const { Items } = await ddbDocClient.send(new ScanCommand(params));
        res.status(200).json(Items);
    } catch (error) {
        console.error('Error fetching products:', error);
        res.status(500).json({ error: 'Error fetching products', errorMessage: error.message });
    }
});

// Update Product
router.put('/prod/:id', authenticateToken, async (req, res) => {
    const { name, description, price, quantity, imageURL, inventory } = req.body;
    const id = req.params.id;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
            UpdateExpression: 'set #name = :name, description = :description, price = :price, quantity = :quantity, imageURL = :imageURL, inventory = :inventory',
            ExpressionAttributeNames: { '#name': 'name' },
            ExpressionAttributeValues: { ':name': name, ':description': description, ':price': price, ':quantity': quantity, ':imageURL': imageURL, ':inventory': inventory },
        };
        await ddbDocClient.send(new UpdateCommand(params));
        res.status(200).json({ message: 'Product updated successfully', item: params.Item });
    } catch (error) {
        console.error('Error updating product:', error);
        res.status(500).json({ error: 'Error updating product', errorMessage: error.message });
    }
});

// Delete Product  
router.delete('/prod/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        await ddbDocClient.send(new DeleteCommand(params));
        res.status(200).json({ message: 'Product deleted successfully' });
    } catch (error) {
        console.error('Error deleting product:', error);
        res.status(500).json({ error: 'Error deleting product', errorMessage: error.message });
    }
});

export default router;