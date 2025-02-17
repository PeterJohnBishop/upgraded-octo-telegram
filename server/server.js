import express from 'express';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import cors from 'cors';
import http from 'http';
import jwt from 'jsonwebtoken';
import { Server } from 'socket.io'; 
import apiLogging from './middleware/apiLogging.js';
import AWSS3Routes from './routes/AWS_S3.js';
import AWSRekognitionRoutes from './routes/AWS_Rekognition.js';
import AWSDynamoDBRoutes from './routes/AWS_DynamoDB.js';
import UserRoutesDDB from './routes/UserRoutes_DDB.js';
import ProductRoutesDDB from './routes/ProductRoutes_DDB.js'

import CLickUpAttachmentRoute from './routes/ClickUpAttachment.js'

const app = express();
dotenv.config();

// Middleware
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

      socket.on('verifyToken', (data) => {
          jwt.verify(data.token, process.env.JWT_SECRET, (err, _decoded) => {
              if (err) {
                  socket.emit('tokenVerified', { verified: false });
                  console.log("token invalid")
              } else {
                  socket.emit('tokenVerified', { verified: true });
                  console.log("token verified")
              }
          });
      });

      socket.on('userAuthenticated', (data) => {
        console.log(`${data['user']} is logged in.`)
      })

      socket.on('disconnect', () => {
          console.log('A user disconnected on port:', PORT);
      });
  });
};
configureSocketIO(io); 

// Routes
// app.get('/', (_req, res, _next) => {
//     res.send('Welcome to Symmetrical Server!');
//   });
app.use('/s3', AWSS3Routes);
app.use('/rekognition', AWSRekognitionRoutes);
app.use('/dynamodb', AWSDynamoDBRoutes);
app.use('/users', UserRoutesDDB);
app.use('/products', ProductRoutesDDB)
app.use('/clickup', CLickUpAttachmentRoute);

// Start the server
const PORT = process.env.PORT;
server.listen(PORT, () => {
    console.log(`HTTP server and Socket.IO listening on http://localhost:${PORT}`);
  });
