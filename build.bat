@echo off
SET INNOSETUP=%CD%\nvm.iss
SET ORIG=%CD%
REM SET GOPATH=%CD%\src
SET BIN=%CD%\bin
REM Support for older architectures
SET GOARCH=386

echo Build executable
go build -o %BIN%\nvm.exe -X github.com/appveyor/nvm-windows/cmd/nvm/main.NvmVersion=%APPVEYOR_BUILD_VERSION% cmd\nvm\main.go

for /f %%i in ('"%BIN%\nvm.exe" version') do set AppVersion=%%i
echo nvm.exe v%AppVersion% built.

echo Create the distribution folder
SET DIST=%CD%\dist

echo Remove old build files if they exist.
if exist %DIST% (
  echo Clearing old build in %DIST%
  rd /s /q "%DIST%"
)

echo Create the distribution directory
mkdir "%DIST%"

echo Create the "no install" zip version
for %%a in ("%BIN%") do (buildtools\zip -j -9 -r "%DIST%\nvm-noinstall.zip" "%CD%\LICENSE" %%a\* -x "%BIN%\nodejs.ico")

echo Generate checksums
for %%f in (%DIST%\*.*) do (certutil -hashfile "%%f" MD5 | find /i /v "md5" | find /i /v "certutil" >> "%%f.checksum.txt")

echo NVM for Windows v%AppVersion% build completed.