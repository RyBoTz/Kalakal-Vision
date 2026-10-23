import io
import os
from pathlib import Path
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from ultralytics import YOLO

app = FastAPI(title="Kalakal Vision YOLO Waste Detection API")

# Enable CORS for Flutter web / desktop / mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model
BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "YoloModel" / "YOLO-Waste-Detection" / "best_model.pt"

if not MODEL_PATH.exists():
    raise RuntimeError(f"Model not found at {MODEL_PATH}")

print(f"Loading YOLO Waste model from: {MODEL_PATH}")
model = YOLO(str(MODEL_PATH))
print(f"Loaded classes: {model.names}")


@app.get("/")
def read_root():
    return {
        "status": "online",
        "service": "Kalakal Vision Waste Detection API",
        "classes": model.names,
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Uploaded file is not an image.")

    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image format: {e}")

    # Run YOLO prediction (conf=0.20 to catch objects reasonably)
    results = model.predict(image, conf=0.20, verbose=False)
    res = results[0]

    detections = []
    for box in res.boxes:
        cls_id = int(box.cls)
        cls_name = model.names[cls_id]
        conf = float(box.conf)
        xyxy = box.xyxy[0].tolist()  # [x1, y1, x2, y2]
        detections.append({
            "class_id": cls_id,
            "class_name": cls_name,
            "confidence": round(conf, 4),
            "box": [round(coord, 2) for coord in xyxy],
        })

    # Sort detections by highest confidence
    detections.sort(key=lambda d: d["confidence"], reverse=True)

    top_detection = detections[0] if detections else None

    return {
        "success": True,
        "total_detected": len(detections),
        "top_detection": top_detection,
        "detections": detections,
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("waste_api:app", host="0.0.0.0", port=8000, reload=True)
