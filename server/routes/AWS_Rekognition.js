import express from 'express';
import { RekognitionClient, DetectFacesCommand, CompareFacesCommand, QualityFilter } from '@aws-sdk/client-rekognition';
import fs from 'fs';
import multer from 'multer';
import dotenv from 'dotenv';

const router = express.Router();
const upload = multer({ dest: 'uploads/' });
dotenv.config();

const client = new RekognitionClient({
    region: 'us-east-1', 
    credentials: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    },
  });

  router.route('/analysis').post(upload.single('image'), async (req, res) => {

    const imageBytes = fs.readFileSync(req.file.path);

  // Set up parameters for Rekognition
  const params = {
    Image: { Bytes: imageBytes },
    Attributes: ['ALL'],
  };

  // Call Rekognition
  try {
    const command = new DetectFacesCommand(params);
    const response = await client.send(command);
    fs.unlinkSync(req.file.path); // Clean up uploaded image file
    res.json(response); // Return analysis data
    console.log(response["FaceDetails"]);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error processing image');
  }
  
});

//comparision analysis on images stored locally
router.route('/compare_faces_local').post(upload.array('images', 2), async (req, res) => {
    if (req.files.length !== 2) {
        return res.status(400).send("Please upload exactly two images for comparison.");
    }

    // Read both images as byte data
    const sourceImageBytes = fs.readFileSync(req.files[0].path);
    const targetImageBytes = fs.readFileSync(req.files[1].path);

    // Set up parameters for Rekognition
    const params = {
        SourceImage: { Bytes: sourceImageBytes },
        TargetImage: { Bytes: targetImageBytes },
        SimilarityThreshold: 70
    };

    try {
        const command = new CompareFacesCommand(params);
        const response = await client.send(command);

        // Clean up uploaded images
        req.files.forEach(file => fs.unlinkSync(file.path));

        // Process and format response data
        const faceMatches = response.FaceMatches.map(match => ({
            position: match.Face.BoundingBox,
            similarity: match.Similarity
        }));

        console.log("Face comparison results:", faceMatches);
        res.json({ faceMatches });
    } catch (error) {
        console.error("Error comparing faces:", error);
        res.status(500).send("Error comparing images");
    }
});

router.route('/compare_faces_s3').post(async (req, res) => {

  const { source, target } = req.body;
  // Set up parameters for Rekognition

  const input = { // CompareFacesRequest
    SourceImage: { // Image
      S3Object: { // S3Object
        Bucket: process.env.AWS_REKOGNITION_BUCKET,
        Name: source,
      },
    },
    TargetImage: {
      S3Object: {
        Bucket: process.env.AWS_REKOGNITION_BUCKET,
        Name: target,
      },
    },
    SimilarityThreshold: 70.00,
    // QualityFilter: "NONE" || "AUTO" || "LOW" || "MEDIUM" || "HIGH",
    QualityFilter: "AUTO"
  };

  try {
    const command = new CompareFacesCommand(input);
    const response = await client.send(command);

    // Extract similarity value
    const faceMatches = response.FaceMatches.map(match => ({
      position: match.Face.BoundingBox,
      similarity: match.Similarity,  // This is the similarity value
    }));

    console.log("Face comparison results:", faceMatches);

    // Return similarity value from the first face match
    if (faceMatches.length > 0) {
      res.json({ similarity: faceMatches[0].similarity });
    } else {
      res.status(404).send("No faces matched.");
    }
  } catch (error) {
    console.error("Error comparing faces:", error);
    res.status(500).send("Error comparing images");
  }
});

export default router;

// Facial Analysis Example Response:

// [
//     {
//       AgeRange: { High: 27, Low: 21 },
//       Beard: { Confidence: 67.07061767578125, Value: true },
//       BoundingBox: {
//         Height: 0.3911389708518982,
//         Left: 0.3302565813064575,
//         Top: 0.009935453534126282,
//         Width: 0.2854692041873932
//       },
//       Confidence: 99.99976348876953,
//       Emotions: [
//         [Object], [Object],
//         [Object], [Object],
//         [Object], [Object],
//         [Object], [Object]
//       ],
//       EyeDirection: {
//         Confidence: 99.99557495117188,
//         Pitch: -27.268962860107422,
//         Yaw: -0.9247658252716064
//       },
//       Eyeglasses: { Confidence: 99.91304016113281, Value: false },
//       EyesOpen: { Confidence: 99.29174041748047, Value: true },
//       FaceOccluded: { Confidence: 99.94126892089844, Value: false },
//       Gender: { Confidence: 99.97894287109375, Value: 'Male' },
//       Landmarks: [
//         [Object], [Object], [Object],
//         [Object], [Object], [Object],
//         [Object], [Object], [Object],
//         [Object], [Object], [Object],
//         [Object], [Object], [Object],
//         [Object], [Object], [Object],
//         [Object], [Object], [Object],
//         [Object], [Object], [Object],
//         [Object], [Object], [Object],
//         [Object], [Object], [Object]
//       ],
//       MouthOpen: { Confidence: 99.33079528808594, Value: false },
//       Mustache: { Confidence: 98.44413757324219, Value: false },
//       Pose: {
//         Pitch: -1.2491133213043213,
//         Roll: -8.335159301757812,
//         Yaw: -7.64624547958374
//       },
//       Quality: { Brightness: 80.97685241699219, Sharpness: 92.22801208496094 },
//       Smile: { Confidence: 53.30836868286133, Value: false },
//       Sunglasses: { Confidence: 99.88922119140625, Value: false }
//     }