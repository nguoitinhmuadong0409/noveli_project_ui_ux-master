@echo off
title Noveli Launcher
cls
echo ========================================================
echo                 STARTING NOVELI SERVICES                
echo ========================================================
echo.

:: 1. Setup PATH to ensure node, npm, redis, and postgres are available
set "NODE_DIR=%USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages\OpenJS.NodeJS.LTS_Microsoft.Winget.Source_8wekyb3d8bbwe\node-v24.20.0-win-x64"
set "PGSQL_BIN=C:\Users\Hue\tools\pgsql\bin"
set "REDIS_DIR=%USERPROFILE%\AppData\Local\Microsoft\WinGet\Packages\taizod1024.redis-windows-fork_Microsoft.Winget.Source_8wekyb3d8bbwe\Redis-8.10.2-Windows-x64-msys2"
set "PATH=%NODE_DIR%;%PGSQL_BIN%;%REDIS_DIR%;%PATH%"

set "ROOT_DIR=%~dp0"

:: 2. Check & Start PostgreSQL
echo [1/4] Checking PostgreSQL database...
tasklist /FI "IMAGENAME eq postgres.exe" 2>NUL | find /I /N "postgres.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo       PostgreSQL is already running.
) else (
    echo       Starting PostgreSQL...
    "%PGSQL_BIN%\pg_ctl.exe" -D "C:\Users\Hue\tools\pgsql\data" -l "C:\Users\Hue\tools\pgsql\data\server.log" start
    timeout /t 2 /nobreak >nul
)

:: 3. Check & Start Redis
echo [2/4] Checking Redis cache...
tasklist /FI "IMAGENAME eq redis-server.exe" 2>NUL | find /I /N "redis-server.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo       Redis is already running.
) else (
    echo       Starting Redis...
    start "Noveli Redis" /min "%REDIS_DIR%\redis-server.exe"
    timeout /t 1 /nobreak >nul
)

:: 4. Start Backend
echo [3/4] Starting Backend (Port 4000)...
start "Noveli Backend" cmd /k "title Noveli Backend && set \"PATH=%NODE_DIR%;%PGSQL_BIN%;%REDIS_DIR%;%%PATH%%\" && cd /d \"%ROOT_DIR%backend\" && npm run dev"

:: 5. Start Frontend
echo [4/4] Starting Frontend (Port 3000)...
start "Noveli Frontend" cmd /k "title Noveli Frontend && set \"PATH=%NODE_DIR%;%PGSQL_BIN%;%REDIS_DIR%;%%PATH%%\" && cd /d \"%ROOT_DIR%frontend\" && npm run dev"

echo.
echo ========================================================
echo        All Noveli services launched successfully!
echo   - Backend:  http://localhost:4000
echo   - Frontend: http://localhost:3000
echo ========================================================
echo.
echo Opening browser at http://localhost:3000 in 4 seconds...
timeout /t 4 /nobreak >nul
start http://localhost:3000
