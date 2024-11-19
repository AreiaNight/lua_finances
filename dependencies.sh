#!/bin/bash

# Colores
green="\e[0;32m\033[1m"
nocolor="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yell="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

echo -e "${green}Verifiying dependencies..."
#Verificamos si lua está instalado 
if ! command -v lua &> /dev/null; then}
    echo e- "${red}\nLua is not installed... Installing${nocolor}"
    if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y lua
        elif command -v pacman &> /dev/null; then
            sudo pacman -S lua
        elif command -v dnf &> /dev/null; then
            sudo dnf install lua
        elif
            echo -e "${red}Error, Lua cannot be installed${nocolor}"
            echo -e "${red}[!] Exiting${nocolor}"
            exit 1
        fi
else
    echo -e "${green}Lua is already installed!${nocolor}" 
fi 

# Verificamos si el luarocks está instalado
if ! command -v luarocks &> /dev/null; then
    echo -e "${red}LuaRocks is not installed.${nocolor}\n${purple}[!] Installing${nocolor}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y luarocks
    elif command -v pacman &> /dev/null; then
        sudo pacman -S luarocks
    elif command -v dnf &> /dev/null; then
        sudo dnf install luarocks
    elif
        echo -e "${red}Error, LuaRocks cannot be installed${nocolor}"
        echo -e "${red}[!] Exiting${nocolor}"
        exit 1
    fi
fi

echo -e "${green}Installing json-lua...${nocolor}"
sudo luarocks install json-lua