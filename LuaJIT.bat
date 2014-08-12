@echo off

cd Balau\LuaJIT\src

call "%VS120COMNTOOLS%\..\..\vc\vcvarsall.bat" x86
call ..\..\..\LuaJIT-buildsub.bat static
copy lua51.lib ..\..\..\lua51_32r.lib
call ..\..\..\LuaJIT-buildsub.bat debug static
copy lua51.lib ..\..\..\lua51_32d.lib

call "%VS120COMNTOOLS%\..\..\vc\vcvarsall.bat" x86_amd64
call ..\..\..\LuaJIT-buildsub.bat static
copy lua51.lib ..\..\..\lua51_64r.lib
call ..\..\..\LuaJIT-buildsub.bat debug static
copy lua51.lib ..\..\..\lua51_64d.lib

cd ..\..\..
