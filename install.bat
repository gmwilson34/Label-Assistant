@echo off
setlocal enabledelayedexpansion

:: Check if running with administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please run this script as an administrator.
    pause
    exit /b 1
)

:: Set up temporary directory
set "TEMP_DIR=%TEMP%\Label-Assistant"
mkdir "%TEMP_DIR%" 2>nul

:: Install Python if not already installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Python...
    curl -L "https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe.asc" -o "%TEMP_DIR%\python_installer.exe"
    "%TEMP_DIR%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del "%TEMP_DIR%\python_installer.exe"
)

:: Refresh environment variables
call refreshenv.cmd

:: Install Git if not already installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Git...
    curl -L "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe" -o "%TEMP_DIR%\git_installer.exe"
    "%TEMP_DIR%\git_installer.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
    del "%TEMP_DIR%\git_installer.exe"
)

:: Refresh environment variables again
call refreshenv.cmd

:: Clone the repository (replace with your actual repository URL)
git clone https://github.com/gmwilson34/Label-Assistant.git
cd Label-Assistant

:: Create and activate a virtual environment
python -m venv venv
call venv\Scripts\activate

:: Install dependencies
pip install customtkinter opencv-python-headless Pillow google-generativeai pytesseract

:: Create a shortcut to run the application
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%USERPROFILE%\Desktop\LabelAssistant.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%CD%\venv\Scripts\pythonw.exe" >> CreateShortcut.vbs
echo oLink.Arguments = "%CD%\main.py" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%CD%" >> CreateShortcut.vbs
echo oLink.IconLocation = "%CD%\icon.ico" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript //nologo CreateShortcut.vbs
del CreateShortcut.vbs

:: Clean up
rmdir /s /q "%TEMP_DIR%"

echo Setup complete! A shortcut has been created on your desktop.
pause
