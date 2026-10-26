@echo off
rem Baut Fadenkreuz:
rem   build\fadenkreuz.exe        das Overlay
rem   build\fadenkreuz-oben.exe   dieselbe exe mit UIAccess (laeuft nur signiert unter "Programme")
rem   build\Fadenkreuz-Setup-<Version>.exe, falls Inno Setup 6 installiert ist
rem Voraussetzung: Visual Studio oder die Build Tools mit den C++-Werkzeugen.
rem Icons neu zeichnen (braucht Python mit Pillow): python tools\icons.py
setlocal
set VERSION=1.0.0
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" echo Visual Studio oder die Build Tools fehlen.& exit /b 1
for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VS=%%i"
if not defined VS echo Die C++-Werkzeuge fehlen.& exit /b 1
set "PATH=%PATH%;%ProgramFiles(x86)%\Microsoft Visual Studio\Installer"
call "%VS%\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1
cd /d "%~dp0"
if not exist build mkdir build

rc /nologo /fo build\fadenkreuz.res src\fadenkreuz.rc || exit /b 1
rem Ohne C-Laufzeitbibliothek: kleinere exe, Einsprung "start" in fadenkreuz.c
cl /nologo /c /O1 /W4 /GS- /Zl /Fo:build\fadenkreuz.obj src\fadenkreuz.c || exit /b 1
set LINKEN=/nologo build\fadenkreuz.obj build\fadenkreuz.res /SUBSYSTEM:WINDOWS /ENTRY:start /NODEFAULTLIB kernel32.lib user32.lib gdi32.lib advapi32.lib
link %LINKEN% /OUT:build\fadenkreuz.exe || exit /b 1
link %LINKEN% /OUT:build\fadenkreuz-oben.exe /MANIFEST:EMBED /MANIFESTUAC:"level='asInvoker' uiAccess='true'" || exit /b 1
erase build\fadenkreuz.obj build\fadenkreuz.res
echo Gebaut: build\fadenkreuz.exe und build\fadenkreuz-oben.exe

set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" echo Inno Setup 6 nicht gefunden - das Setup wird nicht gebaut.& exit /b 0
"%ISCC%" /Q /DVersion=%VERSION% installer\fadenkreuz.iss || exit /b 1
echo Gebaut: build\Fadenkreuz-Setup-%VERSION%.exe
