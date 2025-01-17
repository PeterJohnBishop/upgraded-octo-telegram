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
const TABLE_NAME = process.env.PRODUCTS_AWS_DYNAMODB_TABLE_NAME;

function hashString(string) {
    // Normalize the email: lowercase and trim whitespace
    const normalizedString = string.toLowerCase().trim();
    // Create a SHA-256 hash of the normalized email
    const hash = crypto.createHash('sha256').update(normalizedString).digest('hex');
    const numericHash = parseInt(hash.slice(0, 8), 16) % 1000000000;

    return numericHash;
}

const calculateItemSize = (item) => {
    const getSize = (value) => {
        if (typeof value === 'string') return Buffer.byteLength(value, 'utf8');
        if (typeof value === 'number') return value.toString().length;
        if (typeof value === 'boolean' || value === null) return 1;
        if (Array.isArray(value)) return value.reduce((sum, el) => sum + getSize(el), 3); // Add 3 bytes overhead
        if (typeof value === 'object') return Object.entries(value).reduce((sum, [k, v]) => sum + getSize(k) + getSize(v), 3); // Add 3 bytes overhead
        return 0; // Unknown type
    };

    return Object.entries(item).reduce((sum, [key, value]) => {
        return sum + getSize(key) + getSize(value) + 3; // Add 3 bytes overhead
    }, 0);
};

// Create New Product
router.post('/product', authenticateToken, async (req, res) => {
    const { name, description, images, price, category, featured } = req.body;
    const id = `p_${hashString(name)}`;
    try {
        const params = {
            TableName: TABLE_NAME,
            Item: { id, name, description, images, price, category, featured }, 
        };
        
        console.log(params);
        console.log(calculateItemSize(params.Item))
        await ddbDocClient.send(new PutCommand(params));
        res.status(201).json({ message: 'Product created successfully', item: params.Item });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Read - Get a single product by ID
router.get('/product/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const params = {
        TableName: TABLE_NAME,
        Key: { id },
    };
    try {
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        if (!Item) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.status(200).json(Item);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }   
});

// List - Get all products
router.get('/', authenticateToken, async (req, res) => {
    const params = {
        TableName: TABLE_NAME,
    };
    try {
        const { Items } = await ddbDocClient.send(new ScanCommand(params));
        console.log(Items)
        res.status(200).json(Items);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update - Modify an existing product
router.put('/product/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { name, description, images, price, category, featured } = req.body;
    const params = {
        TableName: TABLE_NAME,
        Key: { id },
        UpdateExpression: 'set #name = :name, #description = :description, #images = :images, #price = :price, #category = :category, #featured = :featured',
        ExpressionAttributeNames: {
            '#name': 'name',
            '#description': 'description',
            '#images': 'images',
            '#price': 'price',
            '#cateogry': 'cateogry',
            '#featured': 'featured'
        },
        ExpressionAttributeValues: {
            ':name': name,
            ':description': description,
            ':images': images,
            ':price': price,
            ':category': category,
            ':featured': featured
        },
    };
    try {
        await ddbDocClient.send(new UpdateCommand(params));
        res.status(200).json({ message: 'Product updated successfully', item: params.Item });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Delete - Remove an existing user
router.delete('/product/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const params = {
        TableName: TABLE_NAME,
        Key: { id },
    };
    try {
        await ddbDocClient.send(new DeleteCommand(params));
        res.status(200).json({ message: 'Product deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;