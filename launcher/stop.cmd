@echo off
REM Stops the running Multicarnes launcher (supervisor) and server.
setlocal enabledelayedexpansion
set "RUNDIR=%LOCALAPPDATA%\Multicarnes\run"
REM Kill the supervisor first so it does not restart Puma.
if exist "%RUNDIR%\launcher.pid" (
  set /p LPID=<"%RUNDIR%\launcher.pid"
  taskkill /PID !LPID! /T /F >nul 2>&1
  del "%RUNDIR%\launcher.pid" >nul 2>&1
)
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
