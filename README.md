# php_pdo_informix_linux

Precompiled PHP PECL extension php_pdo_informix and compile scripts for Linux.

Tested to Debian 12 and Informix SDK 4.50 FC10.

You can either use the precompiled versions of informix or compile the pdo from the script in the stuff folder.

[Avis'Github repository](https://github.com/Aevis/php_pdo_informix) offers a precompiled version of pdo informix on Windows.

## Installing Precompiled PHP PECL extension

Prerequisites:
* Informix CSDK installed
* INFORMIXDIR environment variable points to the CSDK install folder (/opt/IBM/informix)

Copy the pdo_informix.so file to the /usr/lib/php/$FOLDER/pdo_informix.so

|   PHP Version | $FOLDER |
|---      |:-:
|   7.0   |  20151012 |
|   7.1   |  20160303 |
|   7.2   |  20170718 |
|   7.3   |  20180731 |
|   7.4   |  20190902 |
|   8.0   |  20200930 |
|   8.1   |  20210902 |
|   8.2   |  20220829 |

Launch the commands :
```sh
echo "extension=pdo_informix.so" | sudo tee /etc/php/$PHP_VERSION/mods-available/pdo_informix.ini
# APACHE 2
sudo ln -s /etc/php/$PHP_VERSION/mods-available/pdo_informix.ini /etc/php/$PHP_VERSION/apache2/conf.d/20-pdo_informix.ini
# PHP CLI
sudo ln -s /etc/php/$PHP_VERSION/mods-available/pdo_informix.ini /etc/php/$PHP_VERSION/cli/conf.d/20-pdo_informix.ini
# PHP FPM
sudo ln -s /etc/php/$PHP_VERSION/mods-available/pdo_informix.ini /etc/php/$PHP_VERSION/fpm/conf.d/20-pdo_informix.ini
```

## Compile PDO Informix

Run the install_compile_pdo_informix.sh script in the stuff folder.

You can also run the install_informix_sdk.sh in the stuff folder to install the informix SDK on the server. 

You will only need to download the SDK from the IBM website.