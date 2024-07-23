@echo off
SETLOCAL EnableDelayedExpansion

:: Enable command echoing for debugging
@echo on

:: Create a log file
echo Starting script execution at %date% %time% > install_log.txt

:: Function to log messages
:LogMessage
echo %date% %time% - %~1 >> install_log.txt
echo %~1

:: Function to check for errors and pause if any
:CheckError
if %ERRORLEVEL% NEQ 0 (
    call :LogMessage "An error occurred during the last operation. Error code: %ERRORLEVEL%"
    pause
    exit /b %ERRORLEVEL%
)

:: Function to set progress flag
:SetProgressFlag
call :LogMessage "Setting progress flag to %1"
echo %1 > install_progress.flag

:: Function to read progress flag
:ReadProgressFlag
set PROGRESS=0
if exist install_progress.flag (
    set /p PROGRESS=<install_progress.flag
)
call :LogMessage "Progress flag read: !PROGRESS!"

:: Check for administrative privileges
call :LogMessage "Checking for administrative privileges..."
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    call :LogMessage "This script requires administrative privileges. Please run this script as an administrator."
    pause
    exit /b 1
)
call :LogMessage "Administrative privileges confirmed."
pause

:: Read the progress flag
call :LogMessage "Reading progress flag..."
call :ReadProgressFlag

:: Install Chocolatey
if !PROGRESS! LSS 1 (
    call :LogMessage "Checking for Chocolatey..."
    where choco >nul 2>&1
    if %errorlevel% neq 0 (
        call :LogMessage "Installing Chocolatey..."
        @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" || (
            call :LogMessage "Failed to install Chocolatey."
            exit /b 1
        )
        call :CheckError
        SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
        refreshenv
    ) else (
        call :LogMessage "Chocolatey is already installed."
    )
    call :SetProgressFlag 1
)
pause

:: Rest of the script continues here...

call :LogMessage "Installation complete!"
call :LogMessage "A shortcut 'LabelAssistant' has been created on your desktop."
pause

call :LogMessage "Press any key to exit..."
pause >nul

:: End of script
call :LogMessage "Script execution completed."
ENDLOCAL
exit /b 0
