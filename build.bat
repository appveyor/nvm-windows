@echo off
SET INNOSETUP=%CD%\nvm.iss
SET ORIG=%CD%
REM SET GOPATH=%CD%\src
SET BIN=%CD%\bin
REM Support for older architectures
SET GOARCH=386

REM Build executable
go build -o %BIN%\nvm.exe cmd\nvm\main.go

for /f %%i in ('"%BIN%\nvm.exe" version') do set AppVersion=%%i
echo nvm.exe v%AppVersion% built.

REM Create the distribution folder
SET DIST=%CD%\dist\%AppVersion%

REM Remove old build files if they exist.
if exist %DIST% (
  echo Clearing old build in %DIST%
  rd /s /q "%DIST%"
)

REM Create the distribution directory
mkdir "%DIST%"

REM Create the "no install" zip version
for %%a in ("%BIN%") do (buildtools\zip -j -9 -r "%DIST%\nvm-noinstall.zip" "%CD%\LICENSE" %%a\* -x "%BIN%\nodejs.ico")

REM Generate update utility
cd .\updater
go build nvm-update.go
move nvm-update.exe %DIST%
cd ..\

REM Generate the installer (InnoSetup)
buildtools\iscc "%INNOSETUP%" "/o%DIST%"
buildtools\zip -j -9 -r "%DIST%\nvm-setup.zip" "%DIST%\nvm-setup.exe"
buildtools\zip -j -9 -r "%DIST%\nvm-update.zip" "%DIST%\nvm-update.exe"

del %DIST%\nvm-update.exe
del %DIST%\nvm-setup.exe

REM Generate checksums
for %%f in (%DIST%\*.*) do (certutil -hashfile "%%f" MD5 | find /i /v "md5" | find /i /v "certutil" >> "%%f.checksum.txt")

REM Cleanup
del %BIN%\nvm.exe
del %BIN%\nvm-update.exe
del %BIN%\nvm-setup.exe

echo NVM for Windows v%AppVersion% build completed.
@echo on
