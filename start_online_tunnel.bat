@echo off
title Ihtiyajati Online Tunnel (Localtunnel)
echo ====================================================
echo   Starting Local Server & Creating Online Tunnel...
echo ====================================================
echo.

:: Start the WhatsApp Gateway in the background
echo 1. Starting WhatsApp Gateway on Port 3000...
start "WhatsApp Gateway" /D "%~dp0whatsapp_gateway" node server.js

timeout /t 3 >nul

:: Start Localtunnel to expose Port 3000 to the public internet
echo 2. Launching Localtunnel...
echo ----------------------------------------------------
echo   Copy the URL below and paste it in your Admin Panel!
echo   Example URL: https://XXXXXX.localtunnel.me/send-otp
echo ----------------------------------------------------
echo.

npx localtunnel --port 3000

pause
