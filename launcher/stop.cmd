@echo off
REM Stops the running Multicarnes server (optional "Detener Multicarnes" shortcut).
setlocal enabledelayedexpansion
set "RUNDIR=%LOCALAPPDATA%\Multicarnes\run"
if exist "%RUNDIR%\puma.pid" (
  set /p PID=<"%RUNDIR%\puma.pid"
  taskkill /PID !PID! /T /F >nul 2>&1
  del "%RUNDIR%\puma.pid" >nul 2>&1
  del "%RUNDIR%\port" >nul 2>&1
  echo Multicarnes detenido.
) else (
  echo No hay ninguna instancia en ejecucion.
)
endlocal
