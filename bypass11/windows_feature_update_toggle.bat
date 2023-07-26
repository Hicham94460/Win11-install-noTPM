@(set '(=)||' <# lean and mean cmd / ps1 hybrid, can paste into powershell console #> @'

@echo off & title WINDOWS FEATURE UPDATE TOGGLE by Hicham94460
rem feature upgrades on 1507 - 22H2 even on Home editions!

::# elevate with native shell by Hicham94460
>nul reg add hkcu\software\classes\.Admin\shell\runas\command /f /ve /d "cmd /x /d /r set \"f0=%%2\"& call \"%%2\" %%3"& set _= %*
>nul fltmc|| if "%f0%" neq "%~f0" (cd.>"%temp%\runas.Admin" & start "%~n0" /high "%temp%\runas.Admin" "%~f0" "%_:"=""%" & exit /b)

::# toggle feature upgrade on/off if no arguments, else "restore" or "block"
for /f "tokens=6 delims=[]. " %%b in ('ver') do set /a BUILD=%%b
set SKIP=10240 10586 14393 15063 16299 17134 17763 18362 18363 19041 19042 19043 19044 19045 22000 22621 22622
set IMAGE=HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image& set NOP=%SystemRoot%\System32\systray.exe
set UPDATE=windowsupdatebox updateassistant updateassistantcheck windows10upgrade windows10upgraderapp& set FEATURE=Restored&;
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersionInfo >nul 2>nul && set FEATURE=Blocked&;
set CL=%1& for %%a in (%1) do if /i %%~a == restore (set FEATURE=Blocked) else if /i %%~a == block (set FEATURE=Restored)

if /i %FEATURE% equ Restored (
  reg add HKLM\SOFTWARE\Microsoft\Windows10Upgrader\Volatile /f /v BlockWUUpgrades /t reg_dword /d 1
  reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v TargetReleaseVersion /t reg_dword /d 1
  reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v TargetReleaseVersionInfo /d 1507
  for %%w in (%SKIP%) do reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability\RecoveredFrom /f /v %%w /t reg_dword /d 1
  reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability\RecoveredFrom /f /v TimeStamp /t reg_qword /d 0
  reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /v EnablePreviewBuild /t reg_dword /d 1
  for %%w in ("Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" ) do (
    reg add "HKLM\%%~w\Config" /f /v DODownloadMode /t reg_dword /d 0
    reg add "HKU\S-1-5-20\%%~w\Settings" /f /v DownloadMode /t reg_dword /d 0
  )
  call "%SystemRoot%\UpdateAssistant\Windows10Upgrade.exe" /PreventWUUpgrade /ForceUninstall 2>nul
  call "%SystemDrive%\Windows10Upgrade\Windows10UpgraderApp.exe" /PreventWUUpgrade /ForceUninstall 2>nul
  for %%w in (%UPDATE%) do reg add "%IMAGE% File Execution Options\%%w.exe" /f /v Debugger /d %NOP% & taskkill /im %%w.exe /f /t
  set STATUS=Feature Upgrade [BLOCKED] run again to restore
) >nul 2>nul

if /i %FEATURE% equ Blocked (
  reg delete HKLM\SOFTWARE\Microsoft\Windows10Upgrader\Volatile /f /v BlockWUUpgrades
  reg delete HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v TargetReleaseVersion
  reg delete HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v TargetReleaseVersionInfo
  for %%w in (%SKIP%) do reg delete HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability\RecoveredFrom /f /v %%w
  reg delete HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability\RecoveredFrom /f /v TimeStamp
  reg delete HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /v EnablePreviewBuild
  for %%w in (%UPDATE%) do reg delete "%IMAGE% File Execution Options\%%w.exe" /f /v Debugger
  set STATUS=Feature Upgrade [RESTORED] run again to block
) >nul 2>nul

echo;& echo;%STATUS%
if not defined CL timeout /t 7
exit /b

'@); $0 = "$env:temp\windows_feature_update_toggle.bat"; ${(=)||} | out-file $0 -encoding default -force; & $0
# press enter
