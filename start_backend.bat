@echo off
title PhishShield Core Engine & SOC Dashboard
echo =======================================================
echo          PhishShield Core Detection Engine
echo =======================================================
echo [1/3] Navigating to backend root...
cd /d "%~dp0backend"

echo [2/3] Starting browser to Web SOC Dashboard...
start http://localhost:8000/dashboard

echo [3/3] Launching FastAPI Core Server with MongoDB Atlas...
..\.venv\Scripts\uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause
