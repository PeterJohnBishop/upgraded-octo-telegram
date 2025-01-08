import express from 'express';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, DeleteCommand, ScanCommand } from '@aws-sdk/lib-dynamodb';
import dotenv from 'dotenv';
import authenticateToken from '../middleware/jwtVerify.js';
import crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';

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

// Review: {
//     id: string; <-- uuidv4()
//     userId: string;
//     productId: string;
//     verified: boolean;
//     rating: number;
//     comment: string;
// }

// Create New Product Review
router.post('/review', authenticateToken, async (req, res) => {
    const { userId, productId, verified, rating, comment } = req.body;
    const id = uuidv4();
    try {
        const params = {
            TableName: TABLE_NAME,
            Item: { id, userId, productId, verified, rating, comment },
        };
        await ddbDocClient.send(new PutCommand(params));
        res.status(201).json({ message: 'Product review created successfully', item: params.Item });
    } catch (error) {
        console.error('Error creating product review:', error);
        res.status(500).json({ error: 'Error creating product review', errorMessage: error.message });
    }
});

// Find Product Review by ID
router.get('/review/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        res.status(200).json({ message: 'Product review found', item: Item });
    } catch (error) {
        console.error('Error finding product review:', error);
        res.status(500).json({ error: 'Error finding product review', errorMessage: error.message });
    }
});

// List All Product Reviews
router.get('/', authenticateToken, async (req, res) => {
    const params = {
        TableName: TABLE_NAME,
    };
    try {
        const { Items } = await ddbDocClient.send(new ScanCommand(params));
        res.status(200).json(Items);
    } catch (error) {
        console.error('Error fetching product reviews:', error);
        res.status(500).json({ error: 'Error fetching product reviews', errorMessage: error.message });
    }
});

// Update Product Review by ID
router.put('/review/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { userId, productId, verified, rating, comment } = req.body;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
            UpdateExpression: 'set userId = :u, productId = :p, verified = :v, rating = :r, comment = :c',
            ExpressionAttributeValues: {
                ':u': userId,
                ':p': productId,
                ':v': verified,
                ':r': rating,
                ':c': comment,
            },
        };
        await ddbDocClient.send(new UpdateCommand(params));
        res.status(200).json({ message: 'Product review updated successfully' });
    } catch (error) {
        console.error('Error updating product review:', error);
        res.status(500).json({ error: 'Error updating product review', errorMessage: error.message });
    }
});

// Delete Product Review by ID
router.delete('/review/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        await ddbDocClient.send(new DeleteCommand(params));
        res.status(200).json({ message: 'Product review deleted successfully' });
    } catch (error) {
        console.error('Error deleting product review:', error);
        res.status(500).json({ error: 'Error deleting product review', errorMessage: error.message });
    }
});

export default router;