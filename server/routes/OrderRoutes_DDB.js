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
};

// Order: {
//     id: string; <-- hashString(Date.now().toString())
//     userId: string; 
//     products: [string]; <-- product IDs
//     total: number;
//     address: string;
// }

// Create New Order
router.post('/order', authenticateToken, async (req, res) => {
    const { userId, products, total, address } = req.body;
    const id = hashString(Date.now().toString());
    try {
        const params = {
            TableName: TABLE_NAME,
            Item: { id, userId, products, total, address },
        };
        await ddbDocClient.send(new PutCommand(params));
        res.status(201).json({ message: 'Order created successfully', item: params.Item });
    } catch (error) {
        console.error('Error creating order:', error);
        res.status(500).json({ error: 'Error creating order', errorMessage: error.message });
    }
});

// Find Order by ID 
router.get('/order/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        if (!Item) {
            return res.status(404).json({ error: 'Order not found' });
        }
        res.status(200).json(Item);
    } catch (error) {
        console.error('Error fetching order:', error);
        res.status(500).json({ error: 'Error fetching order' });
    }
});

// List All Orders
router.get('/', authenticateToken, async (req, res) => {
    const params = {
        TableName: TABLE_NAME,
    };

    try {
        const { Items } = await ddbDocClient.send(new ScanCommand(params));
        res.status(200).json(Items);
    } catch (error) {
        console.error('Error fetching orders:', error);
        res.status(500).json({ error: 'Error fetching orders' });
    }
});

// Update Order
router.put('/order/:id', authenticateToken, async (req, res) => {
    const { userId, products, totalCost, shippingAddress } = req.body;
    const id = req.params.id;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
            UpdateExpression: 'set userId = :u, products = :p, total = :t, address = :a',
            ExpressionAttributeValues: {
                ':u': userId,
                ':p': products,
                ':t': total,
                ':a': address,
            },
        };
        await ddbDocClient.send(new UpdateCommand(params));
        res.status(200).json({ message: 'Order updated successfully' });
    } catch (error) {
        console.error('Error updating order:', error);
        res.status(500).json({ error: 'Error updating order' });
    }
});

// Delete Order
router.delete('/order/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const params = {
            TableName: TABLE_NAME,
            Key: { id },
        };
        await ddbDocClient.send(new DeleteCommand(params));
        res.status(200).json({ message: 'Order deleted successfully' });
    } catch (error) {
        console.error('Error deleting order:', error);
        res.status(500).json({ error: 'Error deleting order' });
    }
});

export default router;