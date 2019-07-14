@echo off
setlocal enabledelayedexpansion

REM https://github.com/RecklessDev/PythonInstallFinder
REM MIT License

REM This scripts looks on the system to find the specified python versions
REM It returns in environment variable PYTHON_INSTALL_DIR the folder where python.exe is found

REM Set the script defaults so they behave consistently
set INTERNAL_SUPPORTED_PYTHON_VERSIONS=
set INTERNAL_PRINT_PYTHON_PATH=0
set PYTHON_INSTALL_DIR=

REM Process command line arguments
:PROCESS_ARGS
if "%1" NEQ "" (
    if "%1" == "-pv" (
        goto PROCESS_ARGS_PYTHON_VERSIONS
    ) else if "%1" == "-h" (
        goto HELP
    ) else if "%1" == "-p" (
        set INTERNAL_PRINT_PYTHON_PATH=1
    ) else if "%1" == "-l" (
        goto LIST_ALL_PYTHON_VERSIONS_FROM_REG
    ) else (
        echo Skipping unrecognized command argument %1
    )
    SHIFT
    goto PROCESS_ARGS
)
goto END_PROCESS_ARGS

REM Format for -pv (meaning python version) is:
REM     -py version_1 version_2 version_3 ... version_n
REM     example: -py 3.6 3.7
REM     For 32 bits the version are of the form M.m-32
:PROCESS_ARGS_PYTHON_VERSIONS
SHIFT
if "%1" == "" goto END_PROCESS_ARGS
SET ARG_PY_V=%1
if "%ARG_PY_V:~0,1%" == "-" goto PROCESS_ARGS
SET INTERNAL_SUPPORTED_PYTHON_VERSIONS=%INTERNAL_SUPPORTED_PYTHON_VERSIONS% %ARG_PY_V% %ARG_PY_V%-32
goto PROCESS_ARGS_PYTHON_VERSIONS

:HELP
echo This script tries to find a valid python installation on the machine of one of the versions provided.
echo First search is done in PATH. If a python is found and its version is one of the accepted one then it selects it.
echo If PATH search failed then it looks into the registry for an installation matching the versions.
echo If it was not found then it simply returns 1.
echo When the python installation is found it sets the variable PYTHON_INSTALL_DIR and returns error code 0
echo.
echo Possible arguments:
echo    -pv v_1 v_2 ... v_n
echo        Mandatory; used to specify the versions. To search for python 3.6 and 3.7 for both 32 and 64 bit:
echo        -pv 3.6 3.7
echo        The first version should be the most preferred one to look for.
echo    -h
echo        This help.
echo    -p
echo        Prints the found python path to the console; should be used with -pv option.
goto END

REM At this point all known parameters should had been processed
:END_PROCESS_ARGS

REM Do validation for inputs
if "%INTERNAL_SUPPORTED_PYTHON_VERSIONS%" == "" (
    echo No python version provided. Please use argument -pv to provide a list of python to check against
    goto HELP
)

REM Look in path first
for %%a in (python.exe) do set PYTHON_INSTALL_DIR=%%~dp$PATH:a
if "%PYTHON_INSTALL_DIR%" NEQ "" (
    for /f "tokens=1,2 usebackq" %%b in (`%PYTHON_INSTALL_DIR%/python.exe -V`) do (
        for %%a in (%INTERNAL_SUPPORTED_PYTHON_VERSIONS%) do (
            set CONSOLE_PY_VERSION=%%c
            if "!CONSOLE_PY_VERSION:~0,3!" == "%%a" (
                set PYTHONVERSION=%%b
                goto END
            )
        )
    )
    REM If we get here it means python is in path but not one of the accepted versions
    set PYTHON_INSTALL_DIR=
)

REM Search for python installation in the registry; this can be in different places depending on the OS
set PYTHONKEY=HKLM\SOFTWARE\Wow6432Node\Python\PythonCore
reg query %PYTHONKEY% >nul 2>nul
if not errorlevel 1 goto GetPythonVersion

set PYTHONKEY=HKLM\SOFTWARE\Python\PythonCore
reg query %PYTHONKEY% >nul 2>nul
if not errorlevel 1 goto GetPythonVersion

SET PYTHONKEY=HKCU\SOFTWARE\Wow6432Node\Python\PythonCore
reg query %PYTHONKEY% >nul 2>nul
if not errorlevel 1 goto GetPythonVersion

SET PYTHONKEY=HKCU\SOFTWARE\Python\PythonCore
reg query %PYTHONKEY% >nul 2>nul
if not errorlevel 1 goto GetPythonVersion

REM At this point we couldn't find registry keys for any python installation
goto ERROR

:GetPythonVersion

for %%a in (%INTERNAL_SUPPORTED_PYTHON_VERSIONS%) do (
    reg query %PYTHONKEY%\%%a\InstallPath >nul 2>nul
    if not errorlevel 1 (
        set PYTHONVERSION=%%a
        GOTO GetPythonPath
    )
)
goto ERROR

:GetPythonPath

for /f "tokens=3" %%a in ('reg query %PYTHONKEY%\%PYTHONVERSION%\InstallPath  /V ""  ^|findstr /ri "REG_SZ"') do set PYTHON_INSTALL_DIR=%%a

goto END

:ERROR

if %INTERNAL_PRINT_PYTHON_PATH%==1 echo Python installation not found.
set PYTHON_INSTALL_DIR=
exit /B 1

:END
if %PYTHON_INSTALL_DIR% == "" goto ERROR

if %INTERNAL_PRINT_PYTHON_PATH%==1 echo %PYTHON_INSTALL_DIR%

endlocal & set PYTHON_INSTALL_DIR=%PYTHON_INSTALL_DIR%

exit /B 0
