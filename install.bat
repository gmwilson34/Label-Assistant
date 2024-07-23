@echo off
SETLOCAL EnableDelayedExpansion

:: Check for administrative privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo This script requires administrative privileges.
    echo Please run this script as an administrator.
    pause
    exit /b 1
)

:: Install Chocolatey
echo Installing Chocolatey...
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: Install Python 3 (latest version)
echo Installing Python 3...
choco install python -y
refreshenv

:: Install Git
echo Installing Git...
choco install git -y
refreshenv

:: Clone the repository (replace with your actual repository URL)
echo Cloning the repository...
git clone https://github.com/gmwilson34/Label-Assistant.git
cd debitchify-work

:: Create and activate virtual environment
echo Creating virtual environment...
python -m venv venv
call venv\Scripts\activate

:: Install dependencies
echo Installing dependencies...
pip install customtkinter opencv-python-headless pillow google-generativeai pytesseract

:: Install Tesseract OCR
echo Installing Tesseract OCR...
choco install tesseract -y
refreshenv

:: Set up Tesseract path (adjust if necessary)
setx TESSDATA_PREFIX "C:\Program Files\Tesseract-OCR\tessdata"
refreshenv

:: Create a batch file to run the application
echo @echo off > run_app.bat
echo call venv\Scripts\activate >> run_app.bat
echo python main.py >> run_app.bat

:: Create a shortcut with the custom icon
echo Creating shortcut with custom icon...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\LabelAssistant.lnk'); $Shortcut.TargetPath = '%CD%\run_app.bat'; $Shortcut.IconLocation = '%CD%\app_icon.ico'; $Shortcut.Save()"

echo Installation complete!
echo A shortcut 'LabelAssistant' has been created on your desktop.
pause
