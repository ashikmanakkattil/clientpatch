
@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

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


REM Check if the script is running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this batch file as Administrator.
    pause
    exit /b
)

REM Get a list of users and add them to the Administrators group
for /f "skip=1 tokens=1" %%i in ('wmic useraccount where "LocalAccount=True" get name') do (
    if not "%%i"=="" (
        echo Adding user %%i to the Administrators group...
        net localgroup Administrators %%i /add
    )
)

echo All users have been added to the Administrators group.



@echo off
echo Clearing Event Logs...

:: Clear Application Event Log
wevtutil cl Application
echo Application Event Log cleared.

:: Clear Security Event Log
wevtutil cl Security
echo Security Event Log cleared.

:: Clear Setup Event Log
wevtutil cl Setup
echo Setup Event Log cleared.

:: Clear System Event Log
wevtutil cl System
echo System Event Log cleared.

echo All specified Event Logs have been cleared.

:: START OF THE SECTION FOR CHANGING THE PC NAME 
:------------------------------------------------

echo.
echo ==================================================
echo "CURRENT COMPUTER NAME: " & hostname
echo ==================================================
echo.
set /p change="Do you want to change the computer name (y/n)? "
if /i "%change%" neq "y" goto skip_computer_name_change

SET /P PCNAME=PLEASE ENTER YOUR DESIRED COMPUTER NAME :

REM Set the computer name in the registry
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName /v ComputerName /t REG_SZ /d %PCNAME% /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName /v ComputerName /t REG_SZ /d %PCNAME% /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters /v Hostname /t REG_SZ /d %PCNAME% /f
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters /v "NV Hostname" /t REG_SZ /d %PCNAME% /f

echo.
echo Computer name changed to %PCNAME% successfully.

@REM Display the new computer name
hostname

:skip_computer_name_change


:: Define the NMS folder path on the C: drive
set nmsPath=C:\NMS

:: Check if stop.bat exists in the NMS folder, then run it
if exist "%nmsPath%\stop.bat" (
    echo Running stop.bat...
    cd /d "%nmsPath%"
    call stop.bat
) else (
    echo stop.bat not found in %nmsPath%
    goto end
)

:: Wait a moment to ensure stop.bat has time to complete
timeout /t 1 /nobreak >nul

:: After running stop.bat, delete the NMS folder
echo Deleting NMS folder...
rmdir /s /q "%nmsPath%"

:: Confirmation message
echo NMS folder and its contents have been deleted.

:end
:: Pause to view the result


cd\
c:
rmdir /s /q C:\NMS

:: Define the network share path
set sharePath=\\192.168.10.34\hydedu\Logs

:: Define the destination path on C: drive
set destPath=C:\Logs

:: Check if destination folder exists, if not create it
if not exist "%destPath%" (
    mkdir "%destPath%"
)

:: Copy all files and subfolders from the network share to the destination
xcopy "%sharePath%" "%destPath%" /E /I /Y

:: Confirmation message
echo Logs folder copied successfully to C:\Logs


:: Define the network share path
set sharePath=\\192.168.10.34\hydedu\NMS

:: Define the destination path on C: drive
set destPath=C:\NMS

:: Check if destination folder exists, if not create it
if not exist "%destPath%" (
    mkdir "%destPath%"
)

:: Copy all files and subfolders from the network share to the destination
xcopy "%sharePath%" "%destPath%" /E /I /Y

:: Confirmation message
echo NMS folder copied successfully to C:\NMS

:: Pause to view the result
@echo off

rem Uninstall program by partial name
wmic product where "Name like '%%_CLIENT_%%' or Name like '%%_Client_%%' or Name like '%%_Client%%'" call uninstall /nointeractive



rem Define the folder names to search for
set "FOLDER_NAME1=_Client_New"
set "FOLDER_NAME2=_CLIENT_SETUP_"

rem Remove folders from Program Files
for /d %%d in ("%ProgramFiles%\*") do (
    echo %%d | findstr /i /c:"%FOLDER_NAME1%" /c:"%FOLDER_NAME2%" >nul
    if not errorlevel 1 (
        echo Removing folder: %%d
        rd /s /q "%%d"
    )
)

rem Remove folders from Program Files (x86)
for /d %%d in ("%ProgramFiles(x86)%\*") do (
    echo %%d | findstr /i /c:"%FOLDER_NAME1%" /c:"%FOLDER_NAME2%" >nul
    if not errorlevel 1 (
        echo Removing folder: %%d
        rd /s /q "%%d"
    )
)

echo Folder removal complete.



xcopy \\192.168.10.34\hydedu\TinyWall-v3-Installer.msi C:\ /f /y




:: Define the destination path on C: drive
set destPath=C:\NMS


:: Check if setup.bat exists, then run it
if exist "%destPath%\setup.bat" (
    echo Running setup.bat...
    cd /d "%destPath%"
    call setup.bat
) else (
    echo setup.bat not found in %destPath%
)

:: Confirmation message
echo NMS folder copied and setup.bat executed.



title BATCH FILE FOR COMPUTER_NAME_CHANGE_IE-POWER_SETTINGS-CLIENT&TINY_INSTALL
:------------------------------------------------------------------------------

mode con cols=110 lines=50 >nul
@echo off
color 0A
CLS



cd\
c:
rmdir /s /q C:\Program Files (x86)\Sepoy_CLIENT_SETUP_2024

rmdir /s /q C:\Program Files\Sepoy_CLIENT_SETUP_2024

:: START OF THIS SECTION FOR SYATEM "DATE & TIMEZONE CHANGE" AUTOMATICALLY(change as required)
:  =====================================================================================================

setlocal

:: Get the date and time from the system at IP 192.168.10.34 using net time
for /f "tokens=*" %%a in ('net time \\192.168.10.34 /set /yes') do set "response=%%a"

:: Display the response (optional)
echo %response%

endlocal

:: Automatically Set Time zone to "(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi"
:  --------------------------------------------------------------------------------

tzutil /s "India Standard Time"


:: END OF THIS SECTION FOR SYATEM "DATE & TIMEZONE CHANGE" AUTOMATICALLY
:  ---------------------------------------------------------------------


:  --------------------------------------------------------------------------------------------
:: DISABLING SECURITY WARNING FOR FILE OPENING
:  -------------------------------------------

reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations /f
reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations /v LowRiskFileTypes /t REG_SZ /d .msi;.exe;.txt;.bat;.config /f

:: END OF ADD TO REGISTRY FOR STARTUP SCRIPT
:  -----------------------------------------

:: START OF COPYING VARIOUS FILES (Change as required)
:  ==================================================


xcopy \\192.168.10.34\hydedu\uninstall.bat %USERPROFILE%\Desktop\ /f /y

xcopy \\192.168.10.34\hydedu\uninstall.bat C:\ /f /y
xcopy \\192.168.10.34\hydedu\Logs.bat %USERPROFILE%\Desktop\ /f /y


:: END OF COPYING VARIOUS FILES
:  ==============================


:: END OF DISABLING REMOTES ACTIVITIES
:  ===================================


:: START OF WINDOWS_SCREEN-SEVER
:  ==============================

cls

:: Windows 7/8/10 screen sever
:  ---------------------------
"HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 0 /f

:: END OF WINDOWS_SCREEN-SEVER
:  ---------------------------

:: START OF WINDOWS_POWER_SETTINGS
:  ===============================
@REM #powercfg -list

@REM #Prefered plan for High performance Power setup.

powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

powercfg -x -monitor-timeout-ac 0
powercfg -x -disk-timeout-ac 0
powercfg -x -standby-timeout-ac 0 
powercfg -x -hibernate-timeout-ac 0

@REM #Prefered plan for Power sever Power setup.
powercfg -setactive a1841308-3541-4fab-bc81-f71556f20b4a

powercfg -x -monitor-timeout-ac 0
powercfg -x -disk-timeout-ac 0
powercfg -x -standby-timeout-ac 0 
powercfg -x -hibernate-timeout-ac 0

@REM #Prefered plan for Balance Power setup.
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e

powercfg -x -monitor-timeout-ac 0
powercfg -x -disk-timeout-ac 0
powercfg -x -standby-timeout-ac 0 
powercfg -x -hibernate-timeout-ac 0

@REM echo press enter for make change all power setting eccept "WHAT POWER BUTTON DOES" THIS WIZARD COME AFTER ALL POWER SETTING AUTO DONE....

powercfg /setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0

powercfg.exe -change -monitor-timeout-ac 0
powercfg.exe -change -disk-timeout-ac 0
powercfg.exe -change -standby-timeout-ac 0
powercfg.exe -change -hibernate-timeout-ac 0

:: END OF WINDOWS_POWER_SETTINGS
: -------------------------------


:: END OF OTHER-SETTING_WINDOWS_THEME_SCREEN-SEVER_WALL-PAPER_POWER_UPDATE
:  ------------------------------------------------------------------------

:: FOR .MSI INSTALLATION (Change as required)
:: ==========================================
msiexec /i \\192.168.10.34\hydedu\Sepoy_CLIENT_SETUP_2024_DEC_V1.msi /qn /norestart >nul 2>&1

:: END OF INSTALLING CLIENT SETUP
:  ------------------------------

:: 5 Seconds Delay for Build Folder Path
:  =====================================
timeout 2

:: START OF Client Setup Installation Folder Permission (Change as required)
:  ========================================================================
@echo off
cls
cd\
cd c:

:: For Users
:-------------
icacls "C:\Program Files\Sepoy_CLIENT_SETUP_2024" /grant Users:(OI)(CI)F /T
icacls "C:\Program Files (x86)\Sepoy_CLIENT_SETUP_2024" /grant Users:(OI)(CI)F /T
icacls "C:\Logs" /grant Users:(OI)(CI)F /T

:: For Everyone
:---------------
icacls "C:\Program Files\Sepoy_CLIENT_SETUP_2024" /grant Everyone:(OI)(CI)F /T
icacls "C:\Program Files (x86)\Sepoy_CLIENT_SETUP_2024" /grant Everyone:(OI)(CI)F /T
icacls "C:\Logs" /grant Everyone:(OI)(CI)F /T

:: END OF Client Setup Installation Folder Permission
:  --------------------------------------------------

:: START OF COPY CLIENT.EXE.config FILE FOR AOTO-ENTERING THE SERVER IP (Change as required)
:: =========================================================================================

systeminfo | findstr /B /C:"OS Version" | find /i "6.1" > NUL && set OS=WIN7 || set OS=WINOTH
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set BIT=32BIT || set BIT=64BIT

IF %OS%==WIN7 IF %BIT%==32BIT (
cd\
C:

xcopy \\192.168.10.34\hydedu\ClientExePro.exe.config "C:\Program Files\Sepoy_CLIENT_SETUP_2024" /f /y

)
IF %OS%==WIN7 IF %BIT%==64BIT (
cd\
C:

xcopy \\192.168.10.34\hydedu\ClientExePro.exe.config "C:\Program Files (x86)\Sepoy_CLIENT_SETUP_2024" /f /y

)

IF %OS%==WINOTH IF %BIT%==32BIT (
cd\
C:

xcopy \\192.168.10.34\hydedu\ClientExePro.exe.config "C:\Program Files\Sepoy_CLIENT_SETUP_2024" /f /y

)
IF %OS%==WINOTH IF %BIT%==64BIT (
cd\
C:

xcopy \\192.168.10.34\hydedu\ClientExePro.exe.config "C:\Program Files (x86)\Sepoy_CLIENT_SETUP_2024" /f /y

)

:: END OF COPY CLIENT.EXE.config FILE FOR AUTO-ENTERING THE SERVER IP
:  ------------------------------------------------------------------

netsh interface ip set dns "Ethernet" static none
@echo off
PowerShell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6"
:: START OF Tiny Firewall installation (Change as required) & (FOR ERROR CODE: 4)
:  ==============================================================================

cls
cd c:\
start TinyWall-v3-Installer.msi /passive


:: End of Tiny Firewall installation 
:  ---------------------------------

:: START OF Setting This Program Run as an Administrator (Change as required)
:: ==========================================================================

REG add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "C:\Program Files\Sepoy_CLIENT_SETUP_2024\ClientExePro.exe" /t REG_SZ /d RUNASADMIN /f
REG add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "C:\Program Files (x86)\Sepoy_CLIENT_SETUP_2024\ClientExePro.exe" /t REG_SZ /d RUNASADMIN /f

 End OF Setting This Program Run as an Administrator:::::::-----
:----------------------------------------------------------------
echo off



:: Main Server IP Address (Change as required)
:  ===========================================
@echo off
setlocal enabledelayedexpansion

rem Loop through each interface
for /f "skip=3 tokens=1,2,3,*" %%A in ('netsh interface show interface') do (
    rem Check if the interface name is not "Ethernet"
    if "%%D" NEQ "Ethernet" (
        echo Disabling interface %%D...
        netsh interface set interface name="%%D" admin=disabled
    )
)
echo Done.


netsh interface ipv6 set global state=disabled

start ping 172.29.123.2 -t

:  ------------------------------
:end
endlocal
