@echo off
title Ihtiyajati WhatsApp Gateway
echo ----------------------------------------------------
echo Starting WhatsApp Gateway Server on Port 3000...
echo ----------------------------------------------------
cd /d "%~dp0"
start /B node server.js
timeout /t 2 >nul
echo Opening QR Code Page in your default browser...
start http://localhost:3000/qr
