import express from 'express';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, DeleteCommand, ScanCommand } from '@aws-sdk/lib-dynamodb';
import dotenv from 'dotenv';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
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

// User: {
//     id: string; <-- hashString(email)
//     name: string;
//     email: string;
//     password: string; c<-- bcrypt.hash(password, 10)
// }

// Create New User
router.post('/user', async (req, res) => {
    const { name, email } = req.body;
    const id = hashString(email);
    try {
        const password = await bcrypt.hash(req.body.password, 10);
        const params = {
            TableName: TABLE_NAME,
            Item: { id, name, email, password }, 
        };
        await ddbDocClient.send(new PutCommand(params));
        res.status(201).json({ message: 'User created successfully', item: params.Item });
    } catch (error) {
        console.error('Error creating user:', error);
        res.status(500).json({ error: 'Error creating user', errorMessage: error.message });
    }
});

// Authenticate User
router.post('/auth', async (req, res) => {
    const user = req.body;
    const params = {
        TableName: TABLE_NAME,
        Key: { id: hashString(user.email) },
    };
    try {
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        if (!Item) {
            return res.status(404).json({ message: 'User not found' });
        }
        bcrypt.compare(user.password, Item.password).then((match) => {
            if (match) {
                const payload = {
                    id: Item.id,
                    email: Item.email,
                };
                jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: 86400 }, (error, token) => {
                    if (error) {
                        return res.status(401).json({ message: error });
                    } else {
                        return res.status(200).json({ message: 'Login Success!', user: Item, jwt: token });
                    }
                });
            } else {
                return res.status(409).json({ message: 'Email or password is incorrect.' });
            }
        });
    } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ error: 'Error fetching user' });
    }   
});

// Read - Get a single user by ID
router.get('/user/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const params = {
        TableName: TABLE_NAME,
        Key: { id },
    };
    try {
        const { Item } = await ddbDocClient.send(new GetCommand(params));
        if (!Item) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json(Item);
    } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ error: 'Error fetching user' });
    }   
});

// List - Get all users
router.get('/users', authenticateToken, async (req, res) => {
    const params = {
        TableName: TABLE_NAME,
    };
    try {
        const { Items } = await ddbDocClient.send(new ScanCommand(params));
        res.status(200).json(Items);
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ error: 'Error fetching users' });
    }
});

// Update - Modify an existing user
router.put('/user/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { name, email } = req.body;
    const params = {
        TableName: TABLE_NAME,
        Key: { id },
        UpdateExpression: 'set #name = :name, #email = :email',
        ExpressionAttributeNames: {
            '#name': 'name',
            '#email': 'email',
        },
        ExpressionAttributeValues: {
            ':name': name,
            ':email': email,
        },
    };
    try {
        await ddbDocClient.send(new UpdateCommand(params));
        res.status(200).json({ message: 'User updated successfully', item: params.Item });
    } catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ error: 'Error updating user' });
    }
});

// Delete - Remove an existing user
router.delete('/user/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const params = {
        TableName: TABLE_NAME,
        Key: { id },
    };
    try {
        await ddbDocClient.send(new DeleteCommand(params));
        res.status(200).json({ message: 'User deleted successfully' });
    } catch (error) {
        console.error('Error deleting user:', error);
        res.status(500).json({ error: 'Error deleting user' });
    }
});

export default router;