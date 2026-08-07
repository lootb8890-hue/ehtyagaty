@echo off
title ihtiyajati Admin Dashboard
echo Starting Ihtiyajati Pure Web Admin Dashboard...
cd /d "%~dp0"
start "" http://localhost:8081
node server.js
