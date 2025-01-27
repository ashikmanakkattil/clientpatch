@echo off
REM Enter Script

:BEGIN
REM Initialize
set SCRIPT_START_EXIT=/B
set SCRIPT_START_RETVAL=0

REM Check Command Line Arguments
set ADD_SCHEDULE_RULE=false

:NEXTARG
if /I "%1" == ""					goto GETSTARTED
if /I "%1" == "NOPAUSE"				set SCRIPT_START_NOPAUSE=true
if /I "%1" == "MANUALNOKILL"		set SCRIPT_START_MANUALNOKILL=true
shift /1
goto NEXTARG

:GETSTARTED
REM Check Elevated Privileges
fsutil dirty query %SystemDrive% >NUL
if %ERRORLEVEL% NEQ 0 (
	echo ERROR: Please rerun this script with administrator or elevated privileges.
	set SCRIPT_START_RETVAL=1
	goto END
)

REM -- START Script --
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
if %ERRORLEVEL% NEQ 0 (
	echo ERROR: Unable to enable Windows extensions.
	set SCRIPT_START_RETVAL=1
	goto END
)

REM -- START Configuration --

REM client_2 Bin Folder Path
set SCRIPT_START_PATH=%~dp0
set INSTALL_PATH=%SCRIPT_START_PATH%
set LOG_FILE=%INSTALL_PATH%\logs.txt

if NOT EXIST "%INSTALL_PATH%" (
	echo ERROR: Unable to find client_2 installed path.
	set SCRIPT_START_RETVAL=1
	goto END
)

for /f "tokens=*" %%a in ('sc query "Schedule"  ^| findstr "RUNNING"') do (
		set ADD_SCHEDULE_RULE=true
)

REM -- START Executation --

REM Setup client_2 Logging Variables
set IS_LOG=1
set START_INSTANCE=true

if "%ADD_SCHEDULE_RULE%" NEQ "true" (
	echo "Scheduler service(Schedule) is not running. Start the Schedule service and try again."
	goto END
)
	

if "%ADD_SCHEDULE_RULE%" EQU "true" (
	schtasks /delete /tn "Client App Updater" /F >>"%LOG_FILE%" 2>&1
)

tasklist /FI "IMAGENAME eq client_1.exe" 2>NUL | find /I /N "client_1.exe" >NUL
if !ERRORLEVEL! EQU 0 (
	(echo client_1 - Try Kill)
	taskkill /F /T /IM client_1.exe
)
(echo client_1 - Stopped)

tasklist /FI "IMAGENAME eq client_2.exe" 2>NUL | find /I /N "client_2.exe" >NUL
if !ERRORLEVEL! EQU 0 (
	(echo client_2 - Try Kill)
	taskkill /F /T /IM client_2.exe
)
(echo client_2 - Stopped)

tasklist /FI "IMAGENAME eq client_3.exe" 2>NUL | find /I /N "client_3.exe" >NUL
if !ERRORLEVEL! EQU 0 (
	taskkill /F /T /IM client_3.exe
)
(echo client_3 - Stopped)

	
REM If Start - Manual NO Kill or NOT

REM -- END Executation --

endlocal
REM -- END Script --

:END
REM Pause Key
if "%SCRIPT_START_NOPAUSE%" NEQ "true" (
	echo Press any key to exit
	pause >nul
)

REM Exit Script
exit %SCRIPT_START_EXIT% %SCRIPT_START_RETVAL%
