import express from 'express';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, DeleteCommand, ScanCommand } from '@aws-sdk/lib-dynamodb';
import dotenv from 'dotenv';
import authenticateToken from '../middleware/jwtVerify.js';
import crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';
import e from 'express';

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
};

// Wishlist: {
//     id: string; <-- uuidv4()
//     userId: string;
//     products: [string]; <-- product IDs
// }

// Create New Wishlist
router.post('/wishlist', authenticateToken, async (req, res) => {
    const { userId, products } = req.body;
    const id = uuidv4();
    try {
        const params = {
            TableName: TABLE_NAME,
            Item: { id, userId, products },
        };
        await ddbDocClient.send(new PutCommand(params));
        res.status(201).json({ message: 'Wishlist created successfully', item: params.Item });
    } catch (error) {
        console.error('Error creating wishlist:', error);
        res.status(500).json({ error: 'Error creating wishlist', errorMessage: error.message });
    }
});

// Find Wishlist by ID
router.get('/wishlist/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        res.status(200).json({ message: 'Wishlist found', item: Item });
    } catch (error) {
        console.error('Error finding wishlist:', error);
        res.status(500).json({ error: 'Error finding wishlist', errorMessage: error.message });
    }
});

// Find All Wishlists
router.get('/', authenticateToken, async (req, res) => {
    try {
        const params = {
            TableName: TABLE_NAME,
        };
        const { Items } = await ddbDocClient.send(new ScanCommand(params));
        res.status(200).json({ message: 'Wishlists found', items: Items });
    } catch (error) {
        console.error('Error fetching wishlists:', error);
        res.status(500).json({ error: 'Error fetching wishlists', errorMessage: error.message });
    }
});

// Update Wishlist by ID
router.put('/wishlist/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { userId, products } = req.body;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
            UpdateExpression: 'SET userId = :userId, products = :products',
            ExpressionAttributeValues: {
                ':userId': userId,
                ':products': products,
            },
        };
        await ddbDocClient.send(new UpdateCommand(params));
        res.status(200).json({ message: 'Wishlist updated successfully' });
    } catch (error) {
        console.error('Error updating wishlist:', error);
        res.status(500).json({ error: 'Error updating wishlist', errorMessage: error.message });
    }
});

// Delete Wishlist by ID
router.delete('/wishlist/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        await ddbDocClient.send(new DeleteCommand(params));
        res.status(200).json({ message: 'Wishlist deleted successfully' });
    } catch (error) {
        console.error('Error deleting wishlist:', error);
        res.status(500).json({ error: 'Error deleting wishlist', errorMessage: error.message });
    }
});

export default router;