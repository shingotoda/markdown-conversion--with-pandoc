del /Q /S 2.html\
for /d %%i in (2.html\*) do rmdir /q /s %%i
del /Q /S 3.markdown-conv\
for /d %%i in (3.markdown-conv\*) do rmdir /q /s %%i

exit