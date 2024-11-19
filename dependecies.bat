@echo off
where luarocks >nul 2>nul
if %errorlevel% neq 0 (
    echo LuaRocks is not installed, try again
    echo https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Windows
    pause
    exit /b 1
)
luarocks install json-lua
pause