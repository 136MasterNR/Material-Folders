@PUSHD "%~dp0"
@CHCP 65001 >NUL
@VERIFY ON
@ECHO OFF
@SETLOCAL ENABLEDELAYEDEXPANSION

:RE
CLS
SET CATEGORY=
SET /P CATEGORY=Folder Category: 
IF NOT EXIST ".\material\folder-!CATEGORY!.ico" ECHO. Doesn't exist on material
IF NOT EXIST ".\material-open\folder-!CATEGORY!.ico" ECHO. Doesn't exist on material-open
IF NOT DEFINED CATEGORY GOTO :RE
ECHO.

:REE
SET NAME=
SET /P NAME=Folder Name: 

IF NOT DEFINED NAME GOTO :RE

(ECHO.F|xcopy .\material\folder-!CATEGORY!.ico .\material\folder-!NAME!.ico /Y)>NUL
(ECHO.F|xcopy .\material-open\folder-!CATEGORY!.ico .\material-open\folder-!NAME!.ico /Y)>NUL
IF EXIST ".\material\folder-!NAME!.ico" IF EXIST ".\material-open\folder-!NAME!.ico" ECHO.Copy successful^^!!&ECHO.


GOTO :REE



PAUSE>NUL

EXIT 0