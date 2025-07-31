import cv2
import torch
import base64
import numpy as np
from flask import Flask, request, jsonify
from ultralytics import YOLO

app = Flask(__name__)

model = YOLO('best.pt')  

class_names = [
    "1 rupee", "1 rupee coin", "10 rupee coin", "10 rupees", "100 rupees",
    "2 rupee", "2 rupee coin", "20 rupee coin", "20 rupees", "200 rupees",
    "2000 rupees", "5 rupee", "5 rupee coin", "50 rupees", "500 rupees"
]


def decode_base64_image(base64_string):
    img_data = base64.b64decode(base64_string)
    np_arr = np.frombuffer(img_data, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    return img


@app.route('/detect', methods=['POST'])
def detect_objects():
    try:
        data = request.json
        if 'image' not in data:
            return jsonify({'error': 'No image provided'}), 400

        image = decode_base64_image(data['image'])

        results = model(image)

        detections = []
        for result in results[0].boxes:
            x1, y1, x2, y2 = map(int, result.xyxy[0])
            confidence = float(result.conf.item())
            class_id = int(result.cls[0].item())
            class_name = model.names[class_id]

            detections.append({
                'class': class_name,
                'confidence': confidence,
                'bbox': [x1, y1, x2, y2]
            })

        return jsonify({'detections': detections})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
