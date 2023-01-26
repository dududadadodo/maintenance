#!/usr/bin/env bash
set -e

version='0.0.1'
# Declare variables
SERVICE_NAME=nginx.service
maintenance_file_path=/etc/nginx/html/server-error-pages

cd "$(dirname $0)"
CURRDIR=$(pwd)
SCRIPT_FILENAME=$(basename $0)
cd - > /dev/null
sfp=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || greadlink -f "${BASH_SOURCE[0]}" 2>/dev/null)
if [ -z "$sfp" ]; then sfp=${BASH_SOURCE[0]}; fi
SCRIPT_DIR=$(dirname "${sfp}")
ARROW='➜'
DONE='✔'
ERROR='✗'
WARNING='⚠'
RED='\033[0;31m'
BLUE='\033[0;34m'
BBLUE='\033[1;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
DARKORANGE="\033[38;5;208m"
CYAN='\033[0;36m'
DARKGREY="\033[48;5;236m"
NC='\033[0m' # No Color
BOLD="\033[1m"
DIM="\033[2m"
UNDERLINED="\033[4m"
INVERT="\033[7m"
HIDDEN="\033[8m"
# Command arguments
server_name=`echo "$1"`
toggle=`echo "$2"`

show_status () {
  # Add more services if you want to monitor 
  declare -a services=(
    "nginx"
    "httpd"
  )
  declare -a serviceName=(
    "Nginx"
    "Apache"
  )
  declare -a serviceStatus=()
  for service in "${services[@]}"
  do
    serviceStatus+=($(systemctl is-active "$service.service"))
  done
  echo ""
  for i in ${!serviceStatus[@]}
  do
    if [[ "${serviceStatus[$i]}" == "active" ]]; then
      line+="${GREEN}${NC}${serviceName[$i]}: ${GREEN}● ${serviceStatus[$i]}${NC} "
    else
      line+="${serviceName[$i]}: ${RED}▲ ${serviceStatus[$i]}${NC} "
    fi
  done
  echo -e "$line"
}

SHOW_STATUS=$(show_status)

# Check input
checkInput() {
  echo ""
  echo -e "${ORANGE}${INVERT}${WARNING}${BOLD} Nginx Maintenance Mode ${NC}"
  echo ""
  echo -e "${ORANGE}${ARROW} Usage:${NC}${GREEN} ./maintenance.sh [hostname] [on/off] ${NC}"
  echo ""
}

INPUT_CHECK=$(checkInput)

# Exit Script
exitScript() {
  printf "${GREEN}"
  printf "${NC}"
  echo -e "
    This script is fueled by coffee ☕
   ${GREEN}${DONE}${NC} ${BBLUE}Github${NC} ${ARROW} ${ORANGE}https://github.com/dududadadodo${NC}
   ${GREEN}${DONE}${NC} ${BBLUE}Gitlab${NC} ${ARROW} ${ORANGE}https://gitlab.com/dududadadodo${NC}
  "
  echo ""
  exit
}

header() {
  printf "${BLUE}"
  cat << EOF
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║                      Nginx Maintenance mode                       ║
║                                                                   ║
║        Easily toggle on or off maintenance mode with nginx        ║
║                                                                   ║
║             Version: $version Maintained by @dudu                 ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
  printf "${NC}"
}

# Make sure that the script runs with root permissions
function checkPermissions() {
  if [[ "$EUID" != 0 ]]; then
    echo -e "${RED}${ERROR} This action needs root permissions.${NC} Please enter your root password...";
    cd "$CURRDIR"
    su -s "$(which bash)" -c "./$SCRIPT_FILENAME"
    cd - > /dev/null

    exit 0;
  fi
}

# Make sure the maintenance file path exists
function checkDirExists() {
  if [ ! -d "$maintenance_file_path" ]
  then
    echo "Cannot find $maintenance_file_path."
    exit 1
  fi
}

# Check if maintenance mode is off
function checkToggleOn() {
  if [ ! -e "$maintenance_file_path/$server_name-maintenance-page_on.html" ]
  then
    echo -e "${RED}${ERROR} Maintenance mode is already off for $server_name ${NC}"
    echo -e "${SHOW_STATUS} \n"
    exit 1
  fi
}

# Check if maintenance mode is on
function checkToggleOff() {
  if [ -e "$maintenance_file_path/$server_name-maintenance-page_on.html" ]
  then
    echo -e "${RED}${ERROR} Maintenance mode is already on for $server_name ${NC}"
    echo -e "${SHOW_STATUS} \n"
    exit 1
  fi
}

# only runs if nginx -t succeeds
safeReload() {
  nginx -t &&
  systemctl reload $SERVICE_NAME
}

# Restart Nginx
restartNginx () {
  printf "\n-- ${GREEN}${ARROW} reloading Nginx\n\n ${NC}"
  safeReload
  sleep 2
  echo -e "${SHOW_STATUS} "
  #systemctl show -p SubState --value $SERVICE_NAME
  printf "\n"
  echo -e "${GREEN}${DONE} Nginx has been reloaded ${NC}"
  sleep 3
}

#check command input
if [[ -z "$1" && -z "$2" ]];
then
  echo -e "${INPUT_CHECK}"
  exit 0
fi
main() {
  if [ "$2" == "on" ]
  then
    checkPermissions
    checkDirExists
    checkToggleOff
    # Enable Maintenance Mode
    echo -e "${ORANGE}${ARROW} Enabling maintenance mode.. ${NC}"
    cd $maintenance_file_path || exit 1
    cp -rp maintenance-page_off.html $server_name-maintenance-page_on.html
    echo -e "${GREEN}${DONE} Maintenance mode has been enabled ${NC}"
    restartNginx
elif [ "$2" == "off" ]
  then
    checkPermissions
    checkDirExists
    checkToggleOn
    # Disable Maintenance Mode
    echo -e "${ORANGE}${ARROW} Disabling maintenance mode.. ${NC}"
    cd $maintenance_file_path || exit 1
    rm $server_name-maintenance-page_on.html
    echo -e "${GREEN}${DONE} Maintenance mode has been disabled ${NC}"
    restartNginx
  else
    echo -e "${INPUT_CHECK}"
  fi
}

header
main $@
exitScript
