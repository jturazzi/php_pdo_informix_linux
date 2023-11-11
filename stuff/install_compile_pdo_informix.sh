#!/bin/bash
# install_compile_pdo_informix.sh
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
informix_pdo_version=1.3.6
informix_pdo_url=https://raw.githubusercontent.com/jturazzi/php_pdo_informix_linux/main/PDO_INFORMIX-1.3.6.tgz

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

function install_php()
{
step_message 1 "Installing PHP $php_version" "failure"
sudo apt install php$php_version php$php_version-common php$php_version-dev -y
step_message 1 "Installing PHP $php_version" "failure"
}

function download_informix_pdo()
{
   step_message 2 "Download PDO Informix $informix_pdo_version" "failure"
   wget -P /tmp $informix_pdo_url
   step_message 2 "Download PDO Informix $informix_pdo_version" "failure"
}

function extract_informix_pdo() {
    step_message 3 "Decompressing the Informix PDO $informix_pdo_version" "failure"
    cd /tmp/
    sudo tar -xvf PDO_INFORMIX-$informix_pdo_version.tgz
    step_message 3 "Decompressing the Informix PDO $informix_pdo_version" "success"
}

function compile_informix_pdo() {
    step_message 4 "Compiling Informix PDO for PHP $php_version" "failure"
    sudo update-alternatives --set phpize /usr/bin/phpize$php_version
    cd /tmp/PDO_INFORMIX-$informix_pdo_version
    sudo phpize
    sudo ./configure --with-pdo-informix=/opt/IBM/informix --with-php-config=/usr/bin/php-config$php_version
    sudo make
    step_message 4 "Compiling Informix PDO for PHP $php_version" "success"
}

function install_informix_pdo() {
    step_message 5 "Installation Informix PDO" "failure"
    sudo make install
    step_message 5 "Installation Informix PDO" "success"
}

function remove_temporary_folder() {
    step_message 6 "Deleting Informix PDO temporary files" "failure"
    sudo rm -r -v /tmp/PDO_INFORMIX-$informix_pdo_version
    cd /home/houles
    step_message 6 "Deleting Informix PDO temporary files" "success"
}

function configure_php_ini() {
    step_message 7 "Installation PDO in PHP $php_version configuration " "failure"
    echo "extension=pdo_informix.so" | sudo tee /etc/php/$php_version/mods-available/pdo_informix.ini
    sudo ln -s /etc/php/$php_version/mods-available/pdo_informix.ini /etc/php/$php_version/apache2/conf.d/20-pdo_informix.ini
    sudo ln -s /etc/php/$php_version/mods-available/pdo_informix.ini /etc/php/$php_version/cli/conf.d/20-pdo_informix.ini
    sudo ln -s /etc/php/$php_version/mods-available/pdo_informix.ini /etc/php/$php_version/fpm/conf.d/20-pdo_informix.ini
    step_message 7 "Informix PDO installation in PHP $php_version configuration" "success"
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
        echo -e -n "${MAGENTA}- Enter PHP version number for PDO compilation : ${ENDCOLOR}"
        read php_version
        run_function_based_on_argument "$1"
        exit 0
    fi

    echo -e "${CYAN}[Script start $0]${ENDCOLOR}"

    echo -e -n "${MAGENTA}- Enter PHP version number for PDO compilation : ${ENDCOLOR}"
    read php_version

    install_php
    continue_prompt

    download_informix_pdo
    continue_prompt

    extract_informix_pdo
    continue_prompt

    compile_informix_pdo
    continue_prompt

    install_informix_pdo
    continue_prompt

    remove_temporary_folder
    continue_prompt

    configure_php_ini

    echo -e "${CYAN}[Script end $0]${ENDCOLOR}"
}

main "$@"
