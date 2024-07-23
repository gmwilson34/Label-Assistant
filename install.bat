@echo off
SETLOCAL EnableDelayedExpansion

:: Enable command echoing for debugging
@echo on

:: Function to check for errors and pause if any
:CheckError
if %ERRORLEVEL% NEQ 0 (
    echo An error occurred during the last operation. Error code: %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

:: Function to set progress flag
:SetProgressFlag
echo Setting progress flag to %1
echo %1 > install_progress.flag

:: Function to read progress flag
:ReadProgressFlag
set PROGRESS=0
if exist install_progress.flag (
    set /p PROGRESS=<install_progress.flag
)
echo Progress flag read: !PROGRESS!

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

:: Read the progress flag
call :ReadProgressFlag

:: Install Chocolatey
if !PROGRESS! LSS 1 (
    echo Checking for Chocolatey...
    where choco >nul 2>&1
    if %errorlevel% neq 0 (
        echo Installing Chocolatey...
        @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        call :CheckError
        SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
        refreshenv
    ) else (
        echo Chocolatey is already installed.
    )
    call :SetProgressFlag 1
)
pause

:: Install Python 3 (latest version)
if !PROGRESS! LSS 2 (
    echo Checking for Python...
    where python >nul 2>&1
    if %errorlevel% neq 0 (
        echo Installing Python 3...
        choco install python -y
        call :CheckError
        refreshenv
    ) else (
        echo Python is already installed.
    )
    call :SetProgressFlag 2
)
pause

:: Install Git
if !PROGRESS! LSS 3 (
    echo Checking for Git...
    where git >nul 2>&1
    if %errorlevel% neq 0 (
        echo Installing Git...
        choco install git -y
        call :CheckError
        refreshenv
    ) else (
        echo Git is already installed.
    )
    call :SetProgressFlag 3
)
pause

:: Clone the repository (replace with your actual repository URL)
if !PROGRESS! LSS 4 (
    echo Cloning the repository...
    git clone https://github.com/gmwilson34/Label-Assistant
    call :CheckError
    cd Label-Assistant
    call :CheckError
    call :SetProgressFlag 4
)
pause

:: Create and activate virtual environment
if !PROGRESS! LSS 5 (
    echo Creating virtual environment...
    python -m venv venv
    call :CheckError
    call venv\Scripts\activate
    call :CheckError
    call :SetProgressFlag 5
)
pause

:: Install dependencies
if !PROGRESS! LSS 6 (
    echo Installing dependencies...
    pip install customtkinter opencv-python-headless pillow google-generativeai pytesseract
    call :CheckError
    call :SetProgressFlag 6
)
pause

:: Install Tesseract OCR
if !PROGRESS! LSS 7 (
    echo Installing Tesseract OCR...
    choco install tesseract -y
    call :CheckError
    refreshenv
    call :SetProgressFlag 7
)
pause

:: Set up Tesseract path (adjust if necessary)
if !PROGRESS! LSS 8 (
    echo Setting up TESSDATA_PREFIX...
    setx TESSDATA_PREFIX "C:\Program Files\Tesseract-OCR\tessdata"
    call :CheckError
    refreshenv
    call :SetProgressFlag 8
)
pause

:: Create a batch file to run the application
if !PROGRESS! LSS 9 (
    echo Creating run_app.bat...
    echo @echo off > run_app.bat
    echo call venv\Scripts\activate >> run_app.bat
    echo python main.py >> run_app.bat
    call :CheckError
    call :SetProgressFlag 9
)
pause

:: Create a shortcut with the custom icon
if !PROGRESS! LSS 10 (
    echo Creating shortcut with custom icon...
    powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\LabelAssistant.lnk'); $Shortcut.TargetPath = '%CD%\run_app.bat'; $Shortcut.IconLocation = '%CD%\app_icon.ico'; $Shortcut.Save()"
    call :CheckError
    call :SetProgressFlag 10
)
pause

echo Installation complete!
echo A shortcut 'LabelAssistant' has been created on your desktop.
pause

echo Press any key to exit...
pause >nul

:: End of script
ENDLOCAL
exit /b 0
