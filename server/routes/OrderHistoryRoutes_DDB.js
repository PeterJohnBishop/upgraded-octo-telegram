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

// History: {
//     id: string; <-- uuidv4()
//     userId: string;
//     products: [string]; <-- product IDs
//     total: number;
//     address: string;
//     status: string;
// }

// Create New Order History
router.post('/order', authenticateToken, async (req, res) => {
    const { userId, products, total, address, status } = req.body;
    const id = uuidv4();
    try {
        const params = {
            TableName: TABLE_NAME,
            Item: { id, userId, products, total, address, status },
        };
        await ddbDocClient.send(new PutCommand(params));
        res.status(201).json({ message: 'Order history created successfully', item: params.Item });
    } catch (error) {
        console.error('Error creating order history:', error);
        res.status(500).json({ error: 'Error creating order history', errorMessage: error.message });
    }
});

// Find Order History by ID
router.get('/order/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        if (!Item) {
            return res.status(404).json({ error: 'Order history not found' });
        }
        res.status(200).json(Item);
    } catch (error) {
        console.error('Error fetching order history:', error);
        res.status(500).json({ error: 'Error fetching order history' });
    }
});

// List All Order Histories
router.get('/', authenticateToken, async (req, res) => {
    const params = {
        TableName: TABLE_NAME,
    };

    try {
        const { Items } = await ddbDocClient.send(new ScanCommand(params));
        res.status(200).json(Items);
    } catch (error) {
        console.error('Error fetching order histories:', error);
        res.status(500).json({ error: 'Error fetching order histories' });
    }
});

// Update Order History by ID
router.put('/order/:id', authenticateToken, async (req, res) => {
    const { userId, products, total, address, status } = req.body;
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
            UpdateExpression: 'set userId = :u, products = :p, total = :t, address = :a, status = :s',
            ExpressionAttributeValues: {
                ':u': userId,
                ':p': products,
                ':t': total,
                ':a': address,
                ':s': status,
            },
            ReturnValues: 'UPDATED_NEW',
        };
        const { Attributes } = await ddbDocClient.send(new UpdateCommand(params));
        res.status(200).json(Attributes);
    } catch (error) {
        console.error('Error updating order history:', error);
        res.status(500).json({ error: 'Error updating order history', errorMessage: error.message });
    }
});

// Delete Order History by ID
router.delete('/order/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        await ddbDocClient.send(new DeleteCommand(params));
        res.status(200).json({ message: 'Order history deleted successfully' });
    } catch (error) {
        console.error('Error deleting order history:', error);
        res.status(500).json({ error: 'Error deleting order history', errorMessage: error.message });
    }
});

export default router;