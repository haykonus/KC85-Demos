@echo off

set asmfile=..\GleEst_KC85\%1
set option1=
set option2=

if "%1"=="" goto end 
if "%2"=="" goto end 
set file=%1-%2
set binfile="%file%.bin"
set option1="-D KC_TYPE=%2"

if "%3" NEQ "" (
	set binfile="%file%_%3.bin"
        set option2="-D BASE=%3"
)

echo -------- %file% -----------

set bin=C:\Users\Heiko\Nextcloud\Privat\as\bin
%bin%\asw.exe -L %asmfile%.asm -a "%option1%" 
%bin%\p2bin.exe -r $-$ "%asmfile%.p" "%binfile%"
%bin%\plist.exe "%asmfile%.p" 

del %asmfile%.inc
del %asmfile%.p
del %asmfile%.lst
exit /B

:end
echo "use: as <asmfile> <kc_type> [<ORG>]   e.g. gleest_KC85 4 0200H"
exit /B