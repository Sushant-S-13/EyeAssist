<p align="center">
  <img src="https://github.com/user-attachments/assets/7ca210c7-e7cb-4ad5-87c8-6a988a55be3c" alt="EyeAssist Logo" width="150"/>
</p>
<h1 align="center">EyeAssist – Mobile Assistant for the Visually Impaired</h1>


**EyeAssist** is a multi-functional mobile application designed to assist visually impaired individuals through real-time voice interaction, AI-based object detection, text reading, currency recognition, and intelligent image understanding. The app allows users to interact using voice commands and leverages computer vision and natural language processing to respond meaningfully.

---

## 🔍 Problem Statement

Visually impaired individuals often face challenges with navigation, understanding their surroundings, reading text, and identifying objects or money. EyeAssist aims to bridge this gap by providing a smart assistant with four integrated capabilities that promote independence, safety, and accessibility.

---

## 📲 Key Features and How They Work

### 1️⃣ Currency Recognition

**Purpose:**  
To help users recognize Indian currency notes and coins using the smartphone camera.

**Workflow:**
- User points the camera at the currency.
- The app uses a **YOLOv8 object detection model** trained on a **custom currency dataset**.
- Once detected, the class label (e.g., ₹10 note, ₹2 coin) is spoken aloud using **Flutter TTS (Text-to-Speech)**.

**Tech Stack:**
- Object Detection: YOLOv8 (Ultralytics)
- Dataset: Custom dataset of Indian notes and coins with ~800+ annotated images
- Format: `.jpg` images with `.txt` labels (YOLO format)
- Training Tool: Roboflow for dataset preprocessing and annotation

---

### 2️⃣ Read Aloud Mode

**Purpose:**  
To convert printed or handwritten text to speech.

**Workflow:**
- User activates the mode and captures an image of the document or surface.
- The app uses **Google ML Kit’s Text Recognition API** to extract text.
- The extracted text is read aloud to the user using **Flutter’s TTS engine**.

**Tech Stack:**
- OCR: Google ML Kit (on-device, fast and privacy-friendly)
- TTS: Flutter TTS plugin
- Language Support: English (expandable)

**Use Cases:**  
Reading signboards, documents, books, menus, etc.

---

### 3️⃣ Image Chat Mode (Depict Mode)

**Purpose:**  
To help users understand and ask questions about an image.

**Workflow:**
- The user captures an image using the app.
- The image is sent to the **Google Gemini Vision API (multimodal)**.
- The user asks a voice question related to the image (e.g., "What is this person doing?" or "How many people are there?")
- The Gemini model processes the image and question, then returns a descriptive answer.
- The app converts the answer to speech and plays it aloud.

**Tech Stack:**
- Multimodal Reasoning: Google Gemini Vision Pro API
- Voice Input: Flutter Speech-to-Text
- Output: Text response → TTS

**Use Cases:**
- Understand scenes, objects, actions, people, or emotions in the image.
- Describe environments like rooms, gatherings, or food plates.

---

### 4️⃣ Walk Along Mode (Object Detection + Navigation)

**Purpose:**  
To detect nearby objects in real time and guide the user toward or away from them.

**Workflow:**
- Live camera feed is passed to a YOLOv8 model.
- Detected objects are categorized and their positions extracted.
- Using stereo vision (dual camera input), depth maps are generated to estimate distances.
- The system interprets object direction (left/center/right) and distance, converting it into voice instructions like:
  - “Object at 1.5 meters in front”
  - “Move left to avoid obstacle”

**Tech Stack:**
- Object Detection: YOLOv8 (custom trained)
- Distance Estimation: Stereo Vision Depth Estimation (via OpenCV, NumPy)
- Real-time Feedback: Text-to-Speech

**Use Cases:**
- Indoor navigation, obstacle avoidance, directional guidance

---
## Applicable Links
- Dataset : https://app.roboflow.com/sushant-faqf6/indiancurrency/4
- App Link : https://drive.google.com/file/d/1jBwL9tbeKd5IQTm30JaHlhCOkd0WpmR6/view?usp=drive_link
- Trained Model : https://drive.google.com/file/d/10QfIZm1AnvY00jRne40NLghMby3DmoIz/view?usp=drive_link
- App Demo : https://drive.google.com/file/d/11LA3NCtNfGrkw4uLgQgwYktUCY0lNTsi/view?usp=drive_link

---
## 🧠 Architecture Overview

```plaintext
User Input (Voice or Camera)
        ↓
Command Parser (Keyword Extraction)
        ↓
Feature Module (Currency, OCR, Detection, Chat)
        ↓
AI/ML Backend (YOLOv8, Gemini API, ML Kit)
        ↓
Response Engine (TTS, Audio Feedback)
        ↓
User Output (Voice Instructions)


