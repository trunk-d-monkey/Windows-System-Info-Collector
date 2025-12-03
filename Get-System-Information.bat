@echo off
REM BITLOCKER RETRIEVAL 1.0 AUTHORED BY AARON ROBERTS, MSP DFA
REM Use the command prompt opened as administrator
:SETDRIVELETTER
REM Setting where to output the return to.  Administrator command shell
REM starts in Windows\System32 so this needs to know where to put the file to. 
echo . 
echo .
ECHO SYSTEM INFORMATION AND BITLOCKER INFORMATION RETRIEVAL
ECHO .
ECHO This tool will retrieve the following: 
ECHO    Bitlocker keys from drives A through Z for drives unlocked and active on this computer.
ECHO    IP Information for outside and inside IP addresses.
ECHO    General system information.
echo .


REM ECHO What drive is this being run from OR where do you want to output data? (Ex: D)
REM set /p dr="Current Drive: "
REM %dr%:
ECHO If you want to specify an output file path other than the current
ECHO working folder of %cd%, you can do so below.  If nothing is
ECHO entered, the file will be saved in the current folder. 
ECHO When you specify a folder, you don't need the last \.
ECHO .
ECHO    EXAMPLE:   D:    or  D:\Collections
ECHO.
set ans=
set /p ans="SAVE PATH: "

if [%ans%] ==[] (
set dr=%cd%)

if NOT [%ans%] == [] (
set dr=%ans%)
ECHO .
ECHO File will be saved to %dr%
echo .
echo . 

:FILENAMEWARNING
ECHO PROVIDE THE OUTPUT FILE NAME
ECHO    WARNING: When entering names for files DO NOT use spaces.
ECHO    DO NOT USE SPACES.  DO NOT USE SPACES.  DO NOT USE SPACES.
echo    Computer 1 would be Computer_1.  Using spaces will make this crash. 
echo . 
REM Pause

:SETFILENAME
REM Setting the name of your output file (for multiple machines)
echo . 
ECHO What do you want your output file name to be? (Ex: Computer_01)
set fn=
set /p fn="FILE NAME: "

REM Making sure a blank name was not entered.
if [%fn%] == [] (echo You need to enter a name for the file.
echo ...Or enter "exit" to exit this prompt.
goto SETFILENAME)

if [%fn%] == [exit] (Echo exiting
pause
exit)

REM Checking if filename already exists to keep from overwriting files
REM if exist "%dr%:\%fn%.txt" (echo File already exists.  Provide a different name.
if exist "%dr%\%fn%.txt" (echo File already exists.  Provide a different name.
echo ...Or enter "exit" to exit this prompt.
GOTO SETFILENAME)

REM echo Saving information to %dr%:\manage-bde -protectors -get f: >> %sp%
manage-bde -protectors -get f: -sek %dr%%fn%.txt
echo Saving information to %dr%\%fn%.txt
set sp=%dr%\%fn%.txt

:START_ACQUISITION_OF_INFORMATION
REM Get the system info
ECHO Getting system information
systeminfo >> %sp%
echo .

REM Get outside IP
ECHO Getting outside IP
ECHO . >> %sp%
ECHO OUTSIDE IP >>  %sp%
nslookup myip.opendns.com resolver1.opendns.com >> %sp%
ECHO . >> %sp%

REM Get IP Config
ECHO Getting the IP configurations
ECHO . >> %sp%
ECHO IP CONFIG INFORMATION >>  %sp%
ipconfig >> %sp%
ECHO . >> %sp%

REM Display the encryption status of mounted volumes
ECHO Gettins status of volumes
ECHO BITLOCKER STATUS OF VOLUMES A TO Z >> %sp%
manage-bde -status >> %sp%
ECHO .

REM Recover any bitlocker keys
ECHO Retrieving any LOCAL recovery keys for drives A through Z
echo . >> %sp%
echo Drive letters that are not mounted will show a parameter error' >> %sp%
echo These paramater errors can be ignored and are normal. >>%sp%

:: LOOPING FOR STORED IDS AND KEYS
FOR %%G IN (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (

echo . >> %sp%
ECHO Drive %%G
echo DRIVE %%G =============================================== >> %sp%
manage-bde -protectors -get %%G: >> %sp%
)
:: =====================================================================
:: LOOPING FOR EXTERNAL IDS AND KEY FILES
echo Pulling any external bitlocker keys into your target folder.
echo Errors about parameters being incorrect should be ignored
pause

FOR %%G IN (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (

manage-bde -protectors -get %%G: -sek %dr%
)

goto EXITNOW

:EXITERROR
Echo There was an error, terminating. 
Pause
Exit

:EXITNOW
ECHO Key acquisition completed.
Pause
