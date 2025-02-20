@echo off
cd /d "C:\multicarnes"
docker-compose up -d
timeout /t 10 >nul
start chrome http://localhost:3000
pause
