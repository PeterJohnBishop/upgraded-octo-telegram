import express from 'express';
import fs from 'fs';
import multer from 'multer';
import dotenv from 'dotenv';
import axios from 'axios';
import path from 'path';
import FormData from 'form-data';


const router = express.Router();
dotenv.config();
  
// Multer setup for file uploads
const upload = multer({
    dest: 'uploads/', // Temporary folder to store files
    fileFilter: (req, file, cb) => {
      if (file.mimetype === 'application/pdf') {
        cb(null, true);
      } else {
        cb(new Error('Only PDF files are allowed.'));
      }
    },
  });
  
  // POST endpoint to handle file upload
  router.post('/upload', upload.single('file'), async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded.' });
      }
  
      const filePath = path.resolve(req.file.path);
      const fileName = req.file.originalname;
  
      // Create a new FormData instance
      const formData = new FormData();
      formData.append('attachment', fs.createReadStream(filePath), fileName);
  
      // Send the file to ClickUp API
      const clickUpResponse = await axios.post(
        'https://api.clickup.com/api/v2/task/868ajhzx5/attachment',
        formData,
        {
          headers: {
            ...formData.getHeaders(), // Ensure correct headers are included
            'Authorization': process.env.CU_API_KEY,
          },
        }
      );
  
      // Cleanup: delete the uploaded file from the server
      fs.unlinkSync(filePath);
  
      // Send the ClickUp API response back to the client
      res.status(200).json({ message: 'File uploaded successfully!', data: clickUpResponse.data });
    } catch (error) {
      // Handle errors (e.g., API or file system issues)
      console.error(error);
  
      // Cleanup: delete the file in case of errors
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
  
      if (error.response) {
        res.status(error.response.status).json({
          error: error.response.data,
        });
      } else {
        res.status(500).json({
          error: 'Internal server error',
          details: error.message,
        });
      }
    }
  });
  
  

export default router;