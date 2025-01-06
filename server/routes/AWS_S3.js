import express from 'express';
import { S3Client, ListObjectsV2Command } from '@aws-sdk/client-s3';
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
console.log('S3 Object:', s3);

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

async function listAllImages(bucketName) {
  const params = {
      Bucket: bucketName,
      Prefix: 'uploads/', 
  };

  try {
      const command = new ListObjectsV2Command(params);
      const data = await s3.send(command);

      if (data.Contents) {
          return data.Contents.map(item => item.Key); 
      } else {
          return [];
      }
  } catch (error) {
      console.error("Error listing objects:", error);
      throw error;
  }
}

async function deleteImage(bucketName, imageKey) {
  const params = {
      Bucket: bucketName, // Name of your bucket
      Key: imageKey,      // Key of the object to delete
  };

  try {
      await s3.deleteObject(params).promise();
      console.log(`Successfully deleted ${imageKey} from ${bucketName}`);
  } catch (err) {
      console.error('Error deleting object:', err);
  }
}

router.post('/upload', upload.single('image'), async (req, res) => {
  const bucketName = process.env.AWS_BUCKET;
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
    res.status(500).json({ error: error.message });
  }
});

router.get('/list', async (req, res) => {
  const bucketName = process.env.AWS_BUCKET;

  try {
    const images = await listAllImages(bucketName);
    console.log("Images:", images);
    res.status(200).json({ images });
  } catch (error) {
    console.error('Error retrieving images:', error);
    res.status(500).json({ error: 'An error occurred while retrieving images.', details: error.message });
  }
});

router.delete('/delete', async (req, res) => {
  const bucketName = process.env.AWS_BUCKET;
  const imageKey = req.body.key;

  try {
    await deleteImage(bucketName, imageKey);
    res.status(200).json({ message: 'Image deleted' });
  } catch (error) {
    console.error('Error deleting file:', error);
    res.status(500).json({ error: error.message });
  }
});

export default router;