REM save as ANSI/Shift-JIS
@echo off
rem Ensure this file is saved with ANSI/Shift-JIS encoding
setlocal enabledelayedexpansion

rem Initialize environment
set "VENV_PATH=.\myenv"
set "PYTHON_CMD=python"
set "PIP_CMD=pip"
set "LATEST_PIP_VERSION=24.2"

rem Create virtual environment if it doesn't exist
if not exist "%VENV_PATH%\Scripts\activate.bat" (
    echo Creating virtual environment...
    %PYTHON_CMD% -m venv %VENV_PATH%
    if errorlevel 1 (
        echo Error: Failed to create virtual environment.
        exit /b 1
    )
    echo Virtual environment created successfully.
)

rem Activate virtual environment
call %VENV_PATH%\Scripts\activate
if errorlevel 1 (
    echo Error: Failed to activate virtual environment.
    exit /b 1
)

rem Update pip if needed
for /f "tokens=2 delims= " %%a in ('%PIP_CMD% --version') do set "CURRENT_PIP_VERSION=%%a"
if not "%CURRENT_PIP_VERSION%"=="%LATEST_PIP_VERSION%" (
    echo Updating pip to version %LATEST_PIP_VERSION%...
    %PYTHON_CMD% -m pip install --upgrade pip==%LATEST_PIP_VERSION%
    if errorlevel 1 (
        echo Error: Failed to update pip.
        exit /b 1
    )
)

rem Check requirements.txt
if not exist requirements.txt (
    echo Error: requirements.txt not found.
    exit /b 1
)

rem Calculate hash
for /f "skip=1 delims=" %%a in ('certutil -hashfile requirements.txt SHA256') do if not defined CURRENT_HASH set "CURRENT_HASH=%%a"

rem Read stored hash
if exist .req_hash (
    set /p STORED_HASH=<.req_hash
) else (
    set "STORED_HASH="
)

rem Install requirements if needed
if not "%CURRENT_HASH%"=="%STORED_HASH%" (
    echo Installing/updating libraries...
    %PIP_CMD% install -r requirements.txt
    if errorlevel 1 (
        echo Error: Failed to install libraries.
        exit /b 1
    )
    echo %CURRENT_HASH%>.req_hash
    echo Installation completed.
) else (
    echo No changes in requirements.
)

rem Run Python script
if "%1"=="" (
    echo Error: Please specify a Python file to run.
    exit /b 1
)

%PYTHON_CMD% "%1"
if errorlevel 1 (
    echo Error: Failed to run %1
    exit /b 1
)

endlocal