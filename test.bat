@echo off
echo This is a diagnostic script.
echo If you can see this message, the script is running correctly.
echo.
echo Creating a test log file...
echo Test log file > test_log.txt
echo.
if exist test_log.txt (
    echo Test log file created successfully.
) else (
    echo Failed to create test log file.
)
echo.
echo Checking administrative privileges...
NET SESSION >nul 2>&1
if %errorlevel% == 0 (
    echo Script is running with administrative privileges.
) else (
    echo Script is NOT running with administrative privileges.
)
echo.
echo Press any key to exit...
pause >nul
