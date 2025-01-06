import express from 'express';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import cors from 'cors';
import http from 'http';
import { Server } from 'socket.io'; 
const app = express();
dotenv.config();

import apiLogging from './middleware/apiLogging.js';
import AWSS3Routes from './routes/AWS_S3.js';
import AWSRekognitionRoutes from './routes/AWS_Rekognition.js';

// CORS configuration
const allowedOrigins = [
  /^http:\/\/localhost(:\d+)?$/, //localhost:allports
];
const corsOptions = {
  origin: (origin, callback) => {
      if (!origin) {
      // Allow requests with no origin (like mobile apps or curl requests)
      callback(null, true);
      } else if (allowedOrigins.some(o => typeof o === 'string' ? o === origin : o.test(origin))) {
      callback(null, true);
      } else {
      callback(new Error('Not allowed by CORS'));
      }
  },
};
app.use(cors());
app.use(cors(corsOptions));
app.use(bodyParser.json());

app.use(apiLogging);

// Socket.IO configuration 
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: allowedOrigins,
    methods: ["GET", "PUT", "POST", "DELETE"],
    credentials: true,
  },
});
const configureSocketIO = (io) => {
    io.on('connection', (socket) => {
      console.log('A user connected on port:', PORT);
      socket.on('fromSwiftUI', (data) => {
        console.log(`Message received on port ${PORT}:`, data);
      });
      socket.on('fromReact', (data) => {
        console.log(`Message received on port ${PORT}:`, data);
      });
      socket.on('fromFlutter', (data) => {
        console.log(`Message received on port ${PORT}:`, data);
      });
      socket.on('disconnect', () => {
        console.log(`User disconnected from port ${PORT}`);
      });
    });
  };
configureSocketIO(io); 

// Routes
app.get('/', (req, res, next) => {
    res.send('Welcome to Symmetrical Server!');
  });
app.use('/s3', AWSS3Routes);
app.use('/rekognition', AWSRekognitionRoutes);

// Start the server
const PORT = process.env.PORT;
server.listen(PORT, () => {
    console.log(`HTTP server and Socket.IO listening on http://localhost:${PORT}`);
  });
