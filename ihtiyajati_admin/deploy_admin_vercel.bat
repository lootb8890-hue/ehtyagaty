@echo off
title Deploy Ihtiyajati Admin to Vercel
echo ====================================================
echo   Deploying Ihtiyajati Admin Panel to Vercel...
echo ====================================================
cd /d "%~dp0"
npx vercel --prod
pause
