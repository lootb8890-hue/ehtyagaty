@echo off
title Ihtiyajati System Launcher
echo ====================================================
echo   Starting Ihtiyajati System & Services...
echo ====================================================

echo 1. Starting WhatsApp Gateway (Port 3000)...
start "WhatsApp Gateway" /D "%~dp0whatsapp_gateway" node server.js

echo 2. Starting Admin Dashboard (Port 8081)...
start "Admin Dashboard" /D "%~dp0ihtiyajati_admin" node server.js

timeout /t 2 >nul
echo 3. Opening Admin Dashboard in your browser...
start http://localhost:8081

echo ====================================================
echo   ✅ All Services Started Successfully!
echo   Admin Panel: http://localhost:8081
echo   WhatsApp QR/Status: http://localhost:3000/qr
echo ====================================================
