
:: Start Section run a batch file as administrator automatically
:  ===================================================================================
:: Check for administrative permissions
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
:: END OF THE SECTION FOR "RUN AS ADMINISTRATOR" AUTOMATICALLY
:  -----------------------------------------------------------
@echo off

:: Set the Windows Event Log service to start automatically
sc config "EventLog" start= auto
if %errorlevel% == 0 (
    echo Successfully set the Windows Event Log service to Automatic.
) else (
    echo Failed to set the Windows Event Log service to Automatic.
)

:: Check the current status of the Windows Event Log service
for /f "tokens=3" %%a in ('sc query "EventLog" ^| findstr "        STATE"') do (
    set "serviceState=%%a"
)

:: If the service is not running, attempt to start it
if /I "!serviceState!" NEQ "RUNNING" (
    echo The Windows Event Log service is not running. Attempting to start...
    sc start "EventLog"
    if %errorlevel% == 0 (
        echo Successfully started the Windows Event Log service.
    ) else (
        echo Failed to start the Windows Event Log service.
    )
) else (
    echo The Windows Event Log service is already running.
)

endlocal



@echo off
REM Define the directory where logs will be saved
set OUTPUTDIR=C:\Logs

REM Create the output directory if it doesn't exist
if not exist "%OUTPUTDIR%" mkdir "%OUTPUTDIR%"

REM Remove old log files in the directory
del /q "%OUTPUTDIR%\*.evtx"


REM Export System log
set LOGNAME=System
set OUTPUTPATH=%OUTPUTDIR%\SystemEvents.evtx
wevtutil epl %LOGNAME% "%OUTPUTPATH%"
echo Exported %LOGNAME% log to %OUTPUTPATH%.

REM Export Application log
set LOGNAME=Application
set OUTPUTPATH=%OUTPUTDIR%\ApplicationEvents.evtx
wevtutil epl %LOGNAME% "%OUTPUTPATH%"
echo Exported %LOGNAME% log to %OUTPUTPATH%.

REM Export Security log
set LOGNAME=Security
set OUTPUTPATH=%OUTPUTDIR%\SecurityEvents.evtx
wevtutil epl %LOGNAME% "%OUTPUTPATH%"
echo Exported %LOGNAME% log to %OUTPUTPATH%.

REM Export Setup log
set LOGNAME=Setup
set OUTPUTPATH=%OUTPUTDIR%\SetupEvents.evtx
wevtutil epl %LOGNAME% "%OUTPUTPATH%"
echo Exported %LOGNAME% log to %OUTPUTPATH%.

echo All specified event logs have been exported.


:: Set the path where the 7-Zip installer is located
set "INSTALLER_PATH=C:\Logs\7zInstaller.exe"

:: Potential paths to the 7-Zip executable
set "ZIP_EXE_64=C:\Program Files\7-Zip\7z.exe"
set "ZIP_EXE_32=C:\Program Files (x86)\7-Zip\7z.exe"

:: Check if 7-Zip is installed in Program Files or Program Files (x86)
if exist "%ZIP_EXE_64%" (
    set "ZIP_EXE=%ZIP_EXE_64%"
) else if exist "%ZIP_EXE_32%" (
    set "ZIP_EXE=%ZIP_EXE_32%"
) else (
    echo 7-Zip not found, attempting to install...
    "%INSTALLER_PATH%" /S
    :: Check again in both paths after installation
    if exist "%ZIP_EXE_64%" (
        set "ZIP_EXE=%ZIP_EXE_64%"
    ) else if exist "%ZIP_EXE_32%" (
        set "ZIP_EXE=%ZIP_EXE_32%"
    ) else (
        echo Failed to install 7-Zip, exiting.
        exit /b
    )
)

echo 7-Zip installation verified at "%ZIP_EXE%".

:: Specify the folder to compress
set "SOURCE_FOLDER=C:\Logs"

REM Generate a date and timestamp in the format of DD_MM_YYYY_HHMMSS
for /f "tokens=2 delims==" %%i in ('wmic OS Get localdatetime /value') do set datetime=%%i
set DATESTAMP=%datetime:~6,2%_%datetime:~4,2%_%datetime:~0,4%
set TIMESTAMP=%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%

:: Determine the name for the ZIP file
for %%A in ("%~dp0%SOURCE_FOLDER%") do set "ZIP_FILE=%COMPUTERNAME%_Logs_%DATESTAMP%_%TIMESTAMP%~Edu.zip"


:: Compress the folder
"%ZIP_EXE%" a -tzip "%SOURCE_FOLDER%\%ZIP_FILE%" "%SOURCE_FOLDER%\*.evtx"

:: Confirm completion
echo Folder has been compressed to: "%SOURCE_FOLDER%\%ZIP_FILE%"

REM Define the directory where logs will be saved
set OUTPUTDIR=C:\Logs

REM Remove old log files in the directory
del /q "%OUTPUTDIR%\*.evtx"

endlocal
pause
@echo off
setlocal

shutdown /s /f /t 0

