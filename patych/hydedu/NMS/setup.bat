@echo off
REM Enter Script

:BEGIN
REM Initialize
set SCRIPT_START_EXIT=/B
set SCRIPT_START_RETVAL=0

REM Check Command Line Arguments
set ADD_SCHEDULE_RULE=false
set WIN7=false

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

netsh advfirewall firewall show rule name="TD-Sensors" >NUL
if %ERRORLEVEL% NEQ 0 (
	netsh advfirewall firewall add rule name="TD-Sensors" dir=out action=allow protocol=TCP remoteport=443,8080
	echo INFO: Applied Firewall Settings!!
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

echo Pre-requisite checks for the Setup in progress. This operation will take few minutes to complete. 
REM "%INSTALL_PATH%\VC_redist.x64.exe" /install /quiet /norestart
echo %PROCESSOR_ARCHITECTURE% | find /I /N "x86" >NUL
if !ERRORLEVEL! EQU 0 (
	msiexec /i "%INSTALL_PATH%\Windows.Packet.Filter.3.4.3.1.x86.msi" /qn /norestart
) else (
	msiexec /i "%INSTALL_PATH%\Windows.Packet.Filter.3.2.29.1.x64.msi" /qn /norestart
)
REM -- END Configuration --

REM -- START Executation --

REM Setup client_2 Logging Variables
set IS_LOG=1
set START_INSTANCE=true
REM set /p secondaryIp=Main Server IP: 
REM set /p serverIp=Enter Backup/Aggregator IP: 
REM set /p firewallIp=Enter Firewall IP: 


if "%ADD_SCHEDULE_RULE%" NEQ "true" (
	echo "Scheduler service(Schedule) is not running. Start the Schedule service and try again."
	goto END
)
	

if "%ADD_SCHEDULE_RULE%" EQU "true" (
REM Delete Schedule Jobs for CleanUp & WatchDog
	schtasks /delete /tn "Client App Updater" /F >>"%LOG_FILE%" 2>&1
)

REM Second try client_2 Process Kill
tasklist /FI "IMAGENAME eq client_1.exe" 2>NUL | find /I /N "client_1.exe" >NUL
if !ERRORLEVEL! EQU 0 (
	taskkill /F /T /IM client_1.exe
)

REM Second try client_2 Process Kill
tasklist /FI "IMAGENAME eq client_2.exe" 2>NUL | find /I /N "client_2.exe" >NUL
if !ERRORLEVEL! EQU 0 (
	taskkill /F /T /IM client_2.exe
)

tasklist /FI "IMAGENAME eq client_3.exe" 2>NUL | find /I /N "client_3.exe" >NUL
if !ERRORLEVEL! EQU 0 (
	taskkill /F /T /IM client_3.exe
)

echo %PROCESSOR_ARCHITECTURE% | find /I /N "x86" >NUL
if !ERRORLEVEL! EQU 0 (
	xcopy "%INSTALL_PATH%\x86" "%INSTALL_PATH%" /K /H /Y
) else (
	xcopy "%INSTALL_PATH%\x64" "%INSTALL_PATH%" /K /H /Y
)
REM Create Schedule Jobs for CleanUp & WatchDog
schtasks /create /tn "Client App Updater" /tr "'%INSTALL_PATH%\client_1.exe' -f "%INSTALL_PATH%\conf.txt" -p client_2.exe -q client_3.exe -r \"%INSTALL_PATH%\\\\" -t \"%INSTALL_PATH%\\\\"" /SC MINUTE /ru SYSTEM /F >>"%LOG_FILE%" 2>&1

REM Run Schedule Jobs for WatchDog
schtasks /run /tn "Client App Updater" /I >>"%LOG_FILE%" 2>&1
timeout 4 > NUL

REM Second try client_2 Process Kill
tasklist /FI "IMAGENAME eq client_2.exe" 2>NUL | find /I /N "client_2.exe" >NUL
if !ERRORLEVEL! EQU 0 (
	(echo client_2 Started)
)

tasklist /FI "IMAGENAME eq client_3.exe" 2>NUL | find /I /N "client_3.exe" >NUL
if !ERRORLEVEL! EQU 0 (
	(echo client_3 Started)
)

	
echo Setup Completed!
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
