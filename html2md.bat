@echo off

rem ---------------------------------------
rem The script to convert markdown to html
rem ---------------------------------------


rem Variables
rem ---------------------------------------
set DIR_ORIGINAL_MD=1.original-markdown
set DIR_HTML=2.html
set DIR_CONVERTED_MD=3.markdown-conv
set TRUE=0
set FALSE=1

cls

rem Check pandoc is installed
echo.pandoc installation check
pandoc -v >NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :ERROR "pandoc is not installed. Please install it first"
) else (
    echo "OK"
    echo.
)

rem Check necessary folders exist.
rem If some of them does not exist, they will be created.
rem 
call :createDirIfNotExist %DIR_HTML%\
call :createDirIfNotExist %DIR_CONVERTED_MD%\
echo.


rem 
rem Check if html files exist in %DIR_HTML%
rem
echo Check if html files exist in '%DIR_HTML%'
call :checkFileExistance %DIR_HTML% html
rem "%ERRORLEVEL% == 0:found, 1:not found"
if %ERRORLEVEL% EQU 1 (
	call :ERROR "HTML file not found. Put all html files in '%DIR_HTML%' folder"
) else (
    echo OK
    echo.
)


rem 
rem Check if markdown-conv folder is empty to avoid unexpectedly overriding html files
rem 
echo Check if makrdown-conv folder is empty
call :checkFileExistance %DIR_CONVERTED_MD% md
rem %ERRORLEVEL% = 0:found, 1:not found
if %ERRORLEVEL% EQU 0 (
	call :ERROR "One or more files exist in '%DIR_CONVERTED_MD%' folder. Remove all files in this folder to avoid unexpectedly overriding those files"
) else (
    echo OK
    echo.
)


rem 
rem copy html files with subdirectories
rem 
echo Copy html files from %DIR_HTML% to %DIR_CONVERTED_MD%
xcopy /E %DIR_HTML%\*.html %DIR_CONVERTED_MD%\ >NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :ERROR "Failed to copy html files to %DIR_CONVERTED_MD% folder"
) else (
    echo OK
)
echo.

rem 
rem Convert html to markdown from %DIR_HTML% folder recursively
rem 
echo Conversion start
call :convertHTML2MD %DIR_HTML% %DIR_CONVERTED_MD%
echo conversion finished
echo.


rem 
rem remove html files from %DIR_CONVERTED_MD%
rem 
echo Delete temporary files
del /s /q %DIR_CONVERTED_MD%\*.html >NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :ERROR "Failed to delete temporary files from %DIR_CONVERTED_MD%. Check if there is any markdown file remained in %DIR_CONVERTED_MD% folder."
) else (
    echo OK
    echo.
)
echo.

goto END



:convertHTML2MD
    set ext=html
    rem set srcdir=%1
    set dstdir=%2
    
    cd %dstdir%
    rem for /f "usebackq delims=" %%i in (`dir /b /s *.%ext%`) do (
    for /r %%i in (*.%ext%) do (
        call :HTML2MD "%%i"
    )
    cd /d %~dp0
exit /b

:checkFileExistance
    if %2 EQU html (
        set ext=html
    ) else if %2 EQU md (
        set ext=*
    )
    set workdir=%1
    cd %workdir%
    
    set isFound=%FALSE%
    for /r %%i in (*.%ext%) do (
        rem echo Found: %%i
    	set isFound=%TRUE%
    )
    cd /d %~dp0
exit /b %isFound%



:createDirIfNotExist
setlocal enabledelayedexpansion
	set dirpath=%1
	if %dirpath:~-1% NEQ \ (
		set dirpath=%1\
	)
	if exist %dirpath% (
		rem echo Directory exists: Dir=%dirpath%
	) else (
	    echo Directory does not exists: Dir=%dirpath%.
	    mkdir %dirpath%
	    if !ERRORLEVEL! NEQ 0 (
	    	call :ERROR "Failed to create directory: %dirpath%"
	    ) else (
	        echo %dirpath% is created
	    )
	)
endlocal
exit /b



REM Markdown --> HTML への変換。
:MD2HTML
    set FILE=%~p1%~n1
    rem echo "%FILE%.md"
    set OPT_INMD=-f markdown_strict+markdown_in_html_blocks+fenced_code_blocks+multiline_tables+simple_tables+header_attributes
    pandoc "%FILE%.md" %OPT_INMD% -o "%FILE%.html"
exit /b


REM HTML --> Markdown への変換
:HTML2MD
    set FILE=%~p1%~n1
    set OPT_OUTMD=-t markdown+markdown_in_html_blocks+fenced_code_blocks+multiline_tables+simple_tables --atx-headers
    pandoc "%FILE%.html" %OPT_OUTMD% -o "%FILE%.md"
exit /b


:ERROR
echo.
echo ERROR: %1
echo.

:END
echo DONE!
pause
exit