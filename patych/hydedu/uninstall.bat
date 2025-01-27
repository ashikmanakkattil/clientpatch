

:: Start Section run a batch file as administrator automatically (For 32-bit & 64-bit)
:  ===================================================================================
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
@echo off
sc config TinyWall start= disabled
sc stop TinyWall

@echo off
:: Find the PID of TinyWall and terminate it

:: Get the PID of TinyWall.exe
for /f "tokens=2" %%a in ('tasklist ^| findstr /i "TinyWall.exe"') do (
    echo Terminating TinyWall.exe with PID %%a
    taskkill /PID %%a /F
)

echo TinyWall.exe has been terminated.

@echo off
:: Uninstall TinyWall using WMIC

echo Looking for TinyWall installation...
wmic product where "name like 'TinyWall%%'" call uninstall /nointeractive

if %errorlevel% equ 0 (
    echo TinyWall has been uninstalled successfully.
) else (
    echo Failed to uninstall TinyWall.
)

@echo off
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
@echo off

cd\
c:
rmdir /s /q C:\NMS

@echo off

rem Uninstall program by partial name
wmic product where "Name like '%%_CLIENT_%%' or Name like '%%_Client_%%' or Name like '%%_Client%%'" call uninstall /nointeractive

@echo off

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
:: START OF "Network Discovery" & "File and Printer Sharing" Disabled From Advanced sharing settings(Control Panel)
:: ================================================================================================================
@echo off
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

:: END OF "Network Discovery" & "File and Printer Sharing" Disabled From Advanced sharing settings(Control Panel)
:  --------------------------------------------------------------------------------------------------------------

:: USB ENABLE(3)
:  -------------
@echo off
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\USBSTOR /v "Start" /t REG_DWORD /d "3" /f
-----------------

:: START OF "Disable & Stop Sharing Service"
:: =========================================
@echo off

sc config "lanmanserver" start=auto
net start server /y

@REM fsmgmt.msc (For manual configuration)

:: END OF "Disable & Stop Sharing Service"
:: ---------------------------------------

:: START OF REMOVEING FOLDER WITH OTHERS FILES  
:  ===========================================




@echo off
:: Set source and destination directories
set sourceDir=C:\Logs
set destDir=\\192.168.10.34\dumplogs

:: Check if source directory exists
if not exist "%sourceDir%" (
    echo Source directory %sourceDir% does not exist.
    exit /b
)

:: Check if destination directory exists
if not exist "%destDir%" (
    echo Destination directory %destDir% does not exist.
    exit /b
)

:: Copy all files from source to destination
echo Copying files from %sourceDir% to %destDir%...
xcopy "%sourceDir%\*" "%destDir%\" /E /H /C /I /Y

:: Notify the user of completion
echo Files copied successfully.
@echo off





REM Delete startinstall.bat from the desktop
del "%USERPROFILE%\Desktop\uninstall.bat" /q

:: END OF REMOVEING FOLDER WITH OTHERS FILES  
:  =========================================
echo to shutdown
pause

@echo off
setlocal

shutdown /s /f /t 0