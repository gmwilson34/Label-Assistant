@echo off
SETLOCAL EnableDelayedExpansion

:: Function to check for errors and pause if any
:CheckError
if %ERRORLEVEL% NEQ 0 (
    echo An error occurred during the last operation. Error code: %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

:: Check for administrative privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo This script requires administrative privileges.
    echo Please run this script as an administrator.
    pause
    exit /b 1
)
echo Administrative privileges confirmed.
pause

:: Install Chocolatey
echo Installing Chocolatey...
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Chocolatey...
    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    call :CheckError
) else (
    echo Chocolatey is already installed.
)
pause

:: Install Python 3 (latest version)
echo Installing Python 3...
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Python 3...
    choco install python -y
    call :CheckError
) else (
    echo Python is already installed.
)
pause

:: Install Git
echo Installing Git...
choco install git -y
call :CheckError
pause

:: Clone the repository (replace with your actual repository URL)
echo Cloning the repository...
git clone https://github.com/gmwilson34/Label-Assistant
call :CheckError
cd Label-Assistant
call :CheckError
pause

:: Create and activate virtual environment
echo Creating virtual environment...
python -m venv venv
call :CheckError
call venv\Scripts\activate
call :CheckError
pause

:: Install dependencies
echo Installing dependencies...
pip install customtkinter opencv-python-headless pillow google-generativeai pytesseract
call :CheckError
pause

:: Install Tesseract OCR
echo Installing Tesseract OCR...
choco install tesseract -y
call :CheckError
pause

:: Set up Tesseract path (adjust if necessary)
setx TESSDATA_PREFIX "C:\Program Files\Tesseract-OCR\tessdata"
call :CheckError
pause

:: Create a batch file to run the application
echo @echo off > run_app.bat
echo call venv\Scripts\activate >> run_app.bat
echo python main.py >> run_app.bat
call :CheckError
pause

:: Create a shortcut with the custom icon
echo Creating shortcut with custom icon...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\LabelAssistant.lnk'); $Shortcut.TargetPath = '%CD%\run_app.bat'; $Shortcut.IconLocation = '%CD%\app_icon.ico'; $Shortcut.Save()"
call :CheckError
pause

echo Installation complete!
echo A shortcut 'LabelAssistant' has been created on your desktop.
pause

:: End of script
ENDLOCAL
exit /b 0
