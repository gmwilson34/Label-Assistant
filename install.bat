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

:: Set up installation directory
set "INSTALL_DIR=%USERPROFILE%\Label-Assistant"
mkdir "%INSTALL_DIR%" 2>nul
cd /d "%INSTALL_DIR%"

:: Install Python if not already installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Python...
    curl -L "https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe" -o "python_installer.exe"
    python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del python_installer.exe
)

:: Refresh environment variables
call refreshenv.cmd

:: Install Git if not already installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Git...
    curl -L "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe" -o "git_installer.exe"
    git_installer.exe /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
    del git_installer.exe
)

:: Refresh environment variables again
call refreshenv.cmd

:: Clone the repository
git clone https://github.com/gmwilson34/Label-Assistant.git .

:: Create and activate a virtual environment
python -m venv venv
call venv\Scripts\activate

:: Install dependencies
pip install customtkinter opencv-python-headless Pillow google-generativeai pytesseract

:: Attempt to create a shortcut
echo Creating shortcut...
powershell -Command "& {$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\LabelAssistant.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\venv\Scripts\pythonw.exe'; $Shortcut.Arguments = '%INSTALL_DIR%\main.py'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.IconLocation = '%INSTALL_DIR%\icon.ico'; $Shortcut.Save()}"

:: Check if shortcut was created successfully
if not exist "%USERPROFILE%\Desktop\LabelAssistant.lnk" (
    echo Shortcut creation failed. Creating a batch file instead.
    echo @echo off > "%USERPROFILE%\Desktop\LabelAssistant.bat"
    echo cd /d "%INSTALL_DIR%" >> "%USERPROFILE%\Desktop\LabelAssistant.bat"
    echo call venv\Scripts\activate.bat >> "%USERPROFILE%\Desktop\LabelAssistant.bat"
    echo python main.py >> "%USERPROFILE%\Desktop\LabelAssistant.bat"
    echo pause >> "%USERPROFILE%\Desktop\LabelAssistant.bat"
    echo Batch file created on your desktop.
) else (
    echo Shortcut created successfully.
)

echo Setup complete! A shortcut or batch file has been created on your desktop.
pause
