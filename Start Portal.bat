@echo off
title Attendance and Salary Portal
cd /d "%~dp0"
echo.
echo  Attendance and Salary Portal is starting...
echo  Browser will open at http://127.0.0.1:8000
echo  KEEP THIS WINDOW OPEN while using the portal. Close it to stop the portal.
echo.
start "" /b cmd /c "timeout /t 4 >nul & start http://127.0.0.1:8000"
".venv\Scripts\python.exe" manage.py runserver 127.0.0.1:8000
pause
