import express from 'express';
import { S3Client } from '@aws-sdk/client-s3';
import { Upload } from '@aws-sdk/lib-storage';
import fs from 'fs';
import multer from 'multer';
import dotenv from 'dotenv';

const router = express.Router();
const upload = multer({ dest: 'uploads/' });
dotenv.config();

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
});

async function uploadImageToS3(filePath, bucketName, key) {
  const fileStream = fs.createReadStream(filePath);

  const upload = new Upload({
    client: s3,
    params: {
      Bucket: bucketName,
      Key: key,
      Body: fileStream,
      ContentType: 'image/jpeg' 
    }
  });

  await upload.done();

  const fileUrl = `https://${bucketName}.s3.amazonaws.com/${key}`;
  return fileUrl;
}

router.post('/upload', upload.single('image'), async (req, res) => {
  const bucketName = process.env.AWS_REKOGNITION_BUCKET;
  const filePath = req.file.path;
  const key = `uploads/${Date.now()}_${req.file.originalname}`;

  try {
    const imageUrl = await uploadImageToS3(filePath, bucketName, key);
    fs.unlinkSync(filePath);
    console.log(imageUrl);
    // console.log(this.name)
    res.status(200).json({ uploadURL: imageUrl });
  } catch (error) {
    console.error('Error uploading file:', error);
    res.status(500).json({ error: 'Failed to upload image' });
  }
});

export default router;