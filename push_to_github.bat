@echo off
title Push Ihtiyajati to GitHub
echo ====================================================
echo   Pushing Ihtiyajati Project to GitHub...
echo ====================================================
echo.
set /p REPO_URL="Enter your GitHub Repository URL (e.g. https://github.com/USERNAME/ihtiyajati.git): "
if "%REPO_URL%"=="" (
    echo Error: No URL provided.
    pause
    exit /b
)

git remote remove origin 2>nul
git remote add origin %REPO_URL%
git branch -M main
git push -u origin main

echo ====================================================
echo   ✅ Successfully Pushed to GitHub!
echo ====================================================
pause
