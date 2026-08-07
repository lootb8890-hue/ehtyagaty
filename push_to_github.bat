@echo off
title Push Ihtiyajati to GitHub
echo ====================================================
echo   Pushing Ihtiyajati Project to GitHub...
echo ====================================================
echo.
echo Target Repository: https://github.com/lootb8890-hue/ehtyagaty.git
echo.

git remote remove origin 2>nul
git remote add origin https://github.com/lootb8890-hue/ehtyagaty.git
git branch -M main
git push -u origin main

echo ====================================================
echo   ✅ Push complete!
echo ====================================================
pause
