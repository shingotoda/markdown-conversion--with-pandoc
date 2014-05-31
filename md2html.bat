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
call :createDirIfNotExist %DIR_ORIGINAL_MD%\
call :createDirIfNotExist %DIR_HTML%\
echo.


rem 
rem Check if markdown files are contained in %DIR_ORIGINAL_MD%
rem
echo Check if markdown files exist in '%DIR_ORIGINAL_MD%'
call :checkFileExistance %DIR_ORIGINAL_MD% md
rem "%ERRORLEVEL% == 0:found, 1:not found"
if %ERRORLEVEL% EQU 1 (
	call :ERROR "markdown file not found. Put all markdown files in '%DIR_ORIGINAL_MD%' folder"
) else (
    echo OK
    echo.
)


rem 
rem Check if html folder is empty to avoid unexpectedly overriding html files
rem 
echo Check if html folder is empty
call :checkFileExistance %DIR_HTML% html
rem %ERRORLEVEL% = 0:found, 1:not found
if %ERRORLEVEL% EQU 0 (
	call :ERROR "One or more files exist in '%DIR_HTML%' folder. Remove all files in this folder to avoid unexpectedly overriding those files"
) else (
    echo OK
    echo.
)


rem 
rem copy markdown files with subdirectories
rem 
echo Copy markdown files from %DIR_ORIGINAL_MD% to %DIR_HTML%
xcopy /E %DIR_ORIGINAL_MD%\*.md %DIR_HTML%\ >NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :ERROR "Failed to copy markdown files to %DIR_HTML% folder"
) else (
    echo OK
)
echo.

rem 
rem Convert markdown to html from %DIR_ORIGINAL_MD% folder recursively
rem 
echo Conversion start
call :convertMarkdown2HTML %DIR_ORIGINAL_MD% %DIR_HTML%
echo conversion finished
echo.


rem 
rem remove markdown files from %DIR_HTML%
rem 
echo Delete temporary files
del /s /q %DIR_HTML%\*.md >NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :ERROR "Failed to delete temporary files in %DIR_HTML%. Check if there is any markdown file remained in %DIR_HTML% folder."
) else (
    echo OK
    echo.
)
echo.

goto END



:convertMarkdown2HTML
    set ext=md
    rem set srcdir=%1
    set dstdir=%2
    
    cd %dstdir%
    rem for /f "usebackq delims=" %%i in (`dir /b /s *.%ext%`) do (
    for /r %%i in (*.%ext%) do (
        call :MD2HTML "%%i"
    )
    cd /d %~dp0
exit /b

:checkFileExistance
    if %2 EQU md (
        set ext=md
    ) else if %2 EQU html (
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