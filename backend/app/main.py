import os
import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse
from pymongo.errors import PyMongoError
from starlette.exceptions import HTTPException as StarletteHTTPException
from app.api.scan import router as scan_router
from app.services.database import database_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        await database_service.connect()
    except PyMongoError:
        # Keep local scanning available while exposing the failed persistence state
        # through the telemetry endpoint and application logs.
        pass
    try:
        yield
    finally:
        await database_service.close()

app = FastAPI(
    title="PhishShield API",
    description="Multi-Source Phishing Detection Core Engine API",
    version="1.0.0",
    lifespan=lifespan,
)

# Enable CORS for Chrome Extensions and mobile clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register scan endpoints
app.include_router(scan_router, prefix="/api", tags=["Scan Engine"])

# Static Files & Web Dashboard Mounting
static_dir = os.path.join(os.path.dirname(__file__), "static")
if os.path.exists(static_dir):
    app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get("/dashboard", response_class=FileResponse)
async def get_dashboard():
    dashboard_path = os.path.join(static_dir, "dashboard.html")
    if os.path.exists(dashboard_path):
        return FileResponse(dashboard_path)
    return {"error": "Dashboard template not found"}

@app.get("/404", response_class=FileResponse)
async def get_404():
    four_o_four_path = os.path.join(static_dir, "404.html")
    if os.path.exists(four_o_four_path):
        return FileResponse(four_o_four_path, status_code=404)
    return {"error": "404 template not found"}

@app.exception_handler(StarletteHTTPException)
async def custom_http_exception_handler(request: Request, exc: StarletteHTTPException):
    if exc.status_code == 404:
        four_o_four_path = os.path.join(static_dir, "404.html")
        if os.path.exists(four_o_four_path):
            return FileResponse(four_o_four_path, status_code=404)
    return FileResponse(os.path.join(static_dir, "404.html"), status_code=exc.status_code) if os.path.exists(os.path.join(static_dir, "404.html")) else {"detail": exc.detail}


@app.exception_handler(RequestValidationError)
async def request_validation_exception_handler(request: Request, exc: RequestValidationError):
    if request.url.path == "/api/scan":
        return JSONResponse(
            status_code=400,
            content={
                "status": "ERROR",
                "message": "Invalid URL or text format provided for threat analysis.",
            },
        )
    return JSONResponse(status_code=422, content={"detail": exc.errors()})


@app.get("/")
async def root():
    return {
        "status": "online",
        "service": "PhishShield Core Engine",
        "version": "1.0.0",
        "web_dashboard": "http://localhost:8000/dashboard",
        "interactive_docs": "http://localhost:8000/docs",
        "telemetry_stream": "http://localhost:8000/api/telemetry"
    }

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
