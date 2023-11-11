#!/bin/bash
# install_informix_sdk.sh
# Author : Jérémy Turazzi
# https://github.com/jturazzi/php_pdo_informix_linux

CYAN="\e[36m"
GREEN="\e[32m"
MAGENTA="\e[35m"
RED="\e[31m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
TOTAL_STEPS=7

# Variables
informix_version=informix-4.50.FC10
informix_url=https://LINK/ibm.csdk.4.50.FC10.LNX.zip # Download SDK IBM Website

function continue_prompt() {
    # Debug
    #read -p "Continue script (o/n) ? " choice
    #case "$choice" in
    #    o|O ) ;;
    #    * ) echo -e "${CYAN}[End script $0]${ENDCOLOR}" ; exit 0 ;;
    #esac
    sleep 0
}

function step_message() {
    local step_number=$1
    local step_description=$2
    local status=$3

    if [[ "$status" == "success" ]]; then
        echo -e "${YELLOW}- [${step_number}/${TOTAL_STEPS}]${ENDCOLOR} ${step_description} [${GREEN}✓${ENDCOLOR}]"
    elif [[ "$status" == "failure" ]]; then
        echo -e "${YELLOW}- [${step_number}/${TOTAL_STEPS}]${ENDCOLOR} ${step_description} [${RED}✗${ENDCOLOR}]"
    else
        echo -e "${YELLOW}- [${step_number}/${TOTAL_STEPS}]${ENDCOLOR} ${step_description}"
    fi
}

function download_informix_sdk() {
    step_message 1 "Download SDK Informix" "failure"
    wget -P /tmp/$informix_version $informix_url
    step_message 1 "Download SDK Informix" "failure"
}

function copy_and_extract_installation_folder() {
    step_message 2 "Copy and unzip the temporary installation folder" "failure"
    cd /tmp/$informix_version/
    sudo unzip *.zip
    sudo chmod +x /tmp/$informix_version/installclientsdk
    step_message 2 "Copy and unzip the temporary installation folder" "success"
}

function install_missing_libraries() {
    step_message 3 "Installing missing libraries" "failure"
    sudo apt install libncurses5-dev libncursesw5-dev libncurses5:amd64 -y
    step_message 3 "Installing missing libraries" "success"
}

function install_informix_sdk() {
    step_message 4 "SDK installation $informix_version" "failure"
    sudo /tmp/$informix_version/installclientsdk -DUSER_INSTALL_DIR="/opt/IBM/$informix_version"
    step_message 4 "SDK installation $informix_version" "success"
}

function create_symbolic_link() {
    step_message 5 "Creating the symbolic link" "failure"
    sudo ln -s /opt/IBM/$informix_version /opt/IBM/informix
    step_message 5 "Creating the symbolic link" "success"
}

function remove_temporary_installation_folder() {
    step_message 6 "Deleting the temporary installation folder" "failure"
    sudo rm -rv /tmp/$informix_version
    step_message 6 "Deleting the temporary installation folder" "success"
}

function configure_informix_sdk() {
    step_message 7 "Informix SDK configuration" "failure"
    sudo tee /etc/ld.so.conf.d/informix.conf >> /dev/null <<EOT 
/opt/IBM/informix/lib
/opt/IBM/informix/lib/esql
/opt/IBM/informix/lib/cli
EOT
    sudo ldconfig

    sudo tee /opt/IBM/informix/etc/sqlhosts >> /dev/null <<EOT 
vmifxdev_net onsoctcp informix_database 1515
EOT
    step_message 7 "Informix SDK configuration" "success"
}

function run_function_based_on_argument() {
    if [ -n "$1" ] && declare -f "$1" > /dev/null; then
        echo "Function execution : $1"
        "$1"
    else
        echo "Unknown function : $1"
        exit 1
    fi
}

function main() {
    if [ $# -eq 1 ]; then
        run_function_based_on_argument "$1"
        exit 0
    fi

    echo -e "${CYAN}[Script start $0]${ENDCOLOR}"

    download_informix_sdk
    continue_prompt

    copy_and_extract_installation_folder
    continue_prompt

    install_missing_libraries
    continue_prompt

    install_informix_sdk
    continue_prompt

    create_symbolic_link
    continue_prompt

    remove_temporary_installation_folder
    continue_prompt

    configure_informix_sdk

    echo -e "${CYAN}[Script end $0]${ENDCOLOR}"
}

main "$@"