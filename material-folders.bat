@PUSHD "%~dp0"
@TITLE Material Folders
@CHCP 65001 >NUL
@VERIFY ON
@ECHO OFF
@SETLOCAL ENABLEDELAYEDEXPANSION

:UI
:: Options - Edit ONLY this to register more icon names
SET SELECT@1=material
SET SELECT@2=material-open
SET SELECT@3=vscode
SET SELECT@4=vscode-open


SET CURSOR=1
SET MAX=0
FOR /F "TOKENS=1DELIMS==" %%1 IN ('SET SELECT@ 2^>NUL') DO SET /A MAX+=1
ECHO.

:RE
FOR /F "TOKENS=1DELIMS==" %%1 IN ('SET CURSOR@ 2^>NUL') DO SET %%1= 
SET CURSOR@!CURSOR!=^^^<

ECHO.[sSelect a Theme:
ECHO.
ECHO.- - - - -
FOR /L %%I IN (1, 1, !MAX!) DO ECHO.%%I. !SELECT@%%I! !CURSOR@%%I!
ECHO.- - - - -
ECHO.
ECHO.Navigate with W and S, or with numbers.
ECHO.Press ENTER or SPACE to confirm.[u[1A

CALL :CHOICE
IF %CHOICE.INPUT%.==. GOTO :NEXT
IF /I %CHOICE.INPUT%==SPACE GOTO :NEXT
IF /I %CHOICE.INPUT%==S IF NOT !CURSOR! GEQ !MAX! SET /A CURSOR+=1
IF /I %CHOICE.INPUT%==W IF NOT !CURSOR! LEQ 1 SET /A CURSOR-=1
FOR /L %%I IN (1, 1, !MAX!) DO IF /I %CHOICE.INPUT%==%%I SET CURSOR=%%I
GOTO :RE

:NEXT
SET "ICONS=%LOCALAPPDATA%\Material-Icons\!SELECT@%CURSOR%!"
SET THEME=!SELECT@%CURSOR%!

FOR /F "TOKENS=1DELIMS==" %%1 IN ('SET SELECT@ 2^>NUL') DO SET %%1=
SET CURSOR=1
SET SELECT@1=Confirm
SET SELECT@2=Cancel
SET MAX=0
FOR /F "DELIMS=" %%1 IN ('SET SELECT@ 2^>NUL') DO SET /A MAX+=1

CLS
ECHO.

:RE-CONFIRM
FOR /F "TOKENS=1DELIMS==" %%1 IN ('SET CURSOR@ 2^>NUL') DO SET %%1= 
SET CURSOR@!CURSOR!=^^^<

ECHO.[sConfirm to update the icons of all folders and subfolders inside the following directory^?
ECHO.^>^> %CD%
ECHO.
ECHO.- - - - -
FOR /L %%I IN (1, 1, !MAX!) DO ECHO.%%I. !SELECT@%%I! !CURSOR@%%I!
ECHO.- - - - -
ECHO.
ECHO.Navigate with W and S, or with numbers.
ECHO.Press ENTER or SPACE to confirm.[u[1A

CALL :CHOICE
IF %CHOICE.INPUT%.==. IF !SELECT@%CURSOR%!==Cancel (EXIT 0) ELSE IF !SELECT@%CURSOR%!==Confirm GOTO :CHANGE-ALL
IF /I %CHOICE.INPUT%==SPACE IF !SELECT@%CURSOR%!==Cancel (EXIT 0) ELSE IF !SELECT@%CURSOR%!==Confirm GOTO :CHANGE-ALL
IF /I %CHOICE.INPUT%==S IF NOT !CURSOR! GEQ !MAX! SET /A CURSOR+=1
IF /I %CHOICE.INPUT%==W IF NOT !CURSOR! LEQ 1 SET /A CURSOR-=1
FOR /L %%I IN (1, 1, !MAX!) DO IF /I %CHOICE.INPUT%==%%I SET CURSOR=%%I
GOTO :RE-CONFIRM

:CHANGE-ALL
CLS

:: Go through all folders
ECHO.Listing folders...
ECHO.
FOR /F "TOKENS=*DELIMS=" %%I IN ('DIR /S /A:D /B ^| findstr /I /V /C:"\\.git\\" /C:"\\node_modules\\"') DO CALL :PROC "%%I"


EXIT /B 0

:PROC
SET "FPATH=%~1\desktop.ini"

FOR %%I IN ("!FPATH!") DO SET "FILE=%%~nI"
FOR %%I IN ("!FPATH!") DO SET "DIRECTORY=%%~dpI"
FOR %%I IN ("!DIRECTORY:~0,-1!") DO SET "DIRNAME=%%~nxI"
SET ICONNAME=!DIRNAME!
SET ICONNAME_S=!ICONNAME:~0,-1!

:: Icon Setup
IF NOT EXIST "!ICONS!" MD "!ICONS!"

IF NOT EXIST "!ICONS!\folder-!DIRNAME!.ico" (
	CURL --fail --ssl-no-revoke "https://raw.githubusercontent.com/136MasterNR/Material-Folders/main/icons/!THEME!/folder-!ICONNAME!.ico" 2>NUL >"!ICONS!\folder-!ICONNAME!.ico"
	
	FOR /F %%I IN ("!ICONS!\folder-!DIRNAME!.ico") DO IF %%~zI EQU 0 (
		DEL /Q "!ICONS!\folder-!DIRNAME!.ico"
		IF NOT EXIST "!ICONS!\folder-!ICONNAME_S!.ico" (
			CURL --fail --ssl-no-revoke "https://raw.githubusercontent.com/136MasterNR/Material-Folders/main/icons/!THEME!/folder-!ICONNAME_S!.ico" 2>NUL >"!ICONS!\folder-!ICONNAME:~0,-1!!.ico"
			FOR /F %%I IN ("!ICONS!\folder-!ICONNAME_S!.ico") DO IF %%~zI EQU 0 (
				DEL /Q "!ICONS!\folder-!ICONNAME_S!.ico"
				EXIT /B 1
			)
		)
		SET ICONNAME=!ICONNAME:~0,-1!
	)
)

:: Read
IF NOT EXIST "!FPATH!" (
	(
		ECHO.[.ShellClassInfo]
		ECHO.[ViewState]
		ECHO.Mode=
		ECHO.Vid=
		ECHO.FolderType=Generic
	)>"!FPATH!" && attrib +s +h "!FPATH!"	
)
CALL :read "!FILE!" "!DIRECTORY!"

:: Change something in the ini - "test" is the file name
FOR /F "TOKENS=1DELIMS==" %%1 IN ('SET desktop:IconResource+AD0-C[') DO SET "%%1="
SET ShellIconInfo=!ICONS!\folder-!ICONNAME!.ico,0
SET "desktop:.ShellClassInfo[IconResource]=!ShellIconInfo!"
SET "desktop:IconResource+AD0-C[!ShellIconInfo:\=+AFw-!]=$_S"

:: Updates the ini file
IF !DIRNAME!==.git attrib -h "!DIRECTORY:~0,-1!"
CALL :write "!FILE!" "!DIRECTORY!"
attrib +r "!DIRECTORY:~0,-1!"
IF !DIRNAME!==.git attrib +h "!DIRECTORY:~0,-1!"

EXIT /B 0


:read
SET FILE=%1
SET FILE=!FILE:"=!
SET FPATH=%2
SET FPATH=!FPATH:"=!

SET CATEGORY=

FOR /F "TOKENS=1,2,*DELIMS=]=" %%1 IN ('TYPE "!FPATH!!FILE!.ini"') DO (
	SET ITEM=%%1
	IF "!ITEM:~0,1!"=="[" (
		SET CATEGORY=!ITEM:[=!
	) ELSE (
		IF "%%2 %%3"==" " (
			SET !FILE!:!CATEGORY![%%1]=$_S
		) ELSE SET !FILE!:!CATEGORY![%%1]=%%2 %%3
	)
)

SET ITEM=

EXIT /B 0


:write
SET FILE=%1
SET FILE=!FILE:"=!
SET FPATH=%2
SET FPATH=!FPATH:"=!

SET CATEGORY=

BREAK>"!FPATH!!FILE!.inibuild"

FOR /F "TOKENS=1,2,*DELIMS=:[=" %%1 IN ('SET !FILE!:') DO (
	SET ITEM=%%3
	SET ITEM=!ITEM:$_S=!
	IF NOT "%%2"=="!CATEGORY!" (
		SET CATEGORY=%%2
		ECHO;[!CATEGORY!]>> "!FPATH!!FILE!.inibuild"
		ECHO;!ITEM:]=!>> "!FPATH!!FILE!.inibuild"
	) ELSE ECHO;!ITEM:]=!>> "!FPATH!!FILE!.inibuild"
)

attrib -s -h "!FPATH!!FILE!.ini"
>NUL MOVE "!FPATH!!FILE!.inibuild" "!FPATH!!FILE!.ini" && (
	attrib +s +h "!FPATH!!FILE!.ini"
	ECHO.Updated !FPATH!
)

EXIT /B 0


:CHOICE
REM : Special thanks to Grub4K for the xcopy input method! (https://gist.github.com/Grub4K/2d3f5875c488164b44454cbf37deae80)

SETLOCAL ENABLEDELAYEDEXPANSION
SET "KEY="

::Set timeout if /t used
IF /I "%1."=="/T." START "CHOICE_AUTO_SKIP" /MIN CMD /C TIMEOUT /T %2^&TASKKILL /IM xcopy.exe /F

::Get user input - provided by Grub4K
FOR /F "DELIMS=" %%A IN ('XCOPY /W "!COMSPEC!" "!COMSPEC!" 2^>NUL ^|^| ECHO.TIMEOUT') DO (
	IF NOT DEFINED KEY SET "KEY=%%A^!"
)
IF !KEY:~-1!==^^ (
	::Escape the escape character, "caret"
	SET "KEY=CARET"
) ELSE IF "!KEY:~-2!"=="&^!" (
	::Escape the seperator character, "and"
	SET "KEY=AND"
) ELSE IF "!KEY:~-8,7!."=="TIMEOUT." (
	::If /T is used and times out, return it
	SET KEY=TIMEOUT
) ELSE (
	::Take out the key from the xcopy message
	SET "KEY=!KEY:~-2,1!"
)

IF /I "%1."=="/T." TASKKILL /FI "WINDOWTITLE eq CHOICE_AUTO_SKIP*" /IM cmd.exe 1>NUL
::Make key returns more understandable
IF NOT DEFINED KEY SET KEY=BLANK
IF "!KEY!"==" " SET KEY=SPACE
IF "!KEY!"=="	" SET KEY=TAB
IF "!KEY!"=="," SET KEY=COMMA
IF "!KEY!"=="=" SET KEY=EQUAL
IF "!KEY!"=="" SET KEY=ENTER

::Pass the key variable outside the current local enviroment
ENDLOCAL&SET CHOICE.INPUT=%KEY%
EXIT /B
