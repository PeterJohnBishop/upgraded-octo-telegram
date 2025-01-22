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
const TABLE_NAME = process.env.ORDERS_AWS_DYNAMODB_TABLE_NAME;

function hashString(string) {
    // Normalize the email: lowercase and trim whitespace
    const normalizedString = string.toLowerCase().trim();
    // Create a SHA-256 hash of the normalized email
    const hash = crypto.createHash('sha256').update(normalizedString).digest('hex');
    const numericHash = parseInt(hash.slice(0, 8), 16) % 1000000000;

    return numericHash;
}

router.post('/order', authenticateToken, async (req, res) => {
    const { user, product, total, name, address, phone } = req.body;
    const timestamp = Date.now()
    const stringTimestamp = timestamp.toString();
    const id = `o_${hashString(`${user}_${stringTimestamp}`)}`;
    try {
        const params = {
            TableName: TABLE_NAME,
            Item: { id, user, timestamp, product, total, name, address, phone }, 
        };
        
        console.log(params);
        console.log(calculateItemSize(params.Item))
        await ddbDocClient.send(new PutCommand(params));
        res.status(201).json({ message: 'Order created successfully', item: params.Item });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});