# esptool-wrapper
Simple (easily audited) PowerShell wrapper for Espressif's **esptool.py** (for Windows users)

Run the script and select from the com ports found:

![esptool_wrapper_choose_comport](https://github.com/br3ttski/esptool-wrapper/assets/4618991/a42443c0-f1e0-4ad1-8de2-70519e5e36c8)

Then navigate the menu to instruct esptool.py what to do:
(esptool.py still interacts with your ESP32 microcontroller)

![esptool_wrapper_menu](https://github.com/br3ttski/esptool-wrapper/assets/4618991/e92eb3d3-10ae-47e7-b0c6-f45b6948148e)

### NOTE this script works best when run directly in PowerShell (not PowerShell ISE)

## Instructions

It has two dependencies on utilities that must already be installed on your PC
1. Espressif ESPtool.py - https://github.com/espressif/esptool
Git clone and run setup.py to install esptool.py into Environment:Path
2. Putty PLink - https://www.chiark.greenend.org.uk/%7Esgtatham/putty/latest.html
Download the MSI installer of Putty and it will install putty link (PLink) too.
My test environment is a Windows 10 PC, your mileage may vary on other OSes.
This script is intended to make using esptool more pleasant, not handling all the
possible things it does. There are other tools if you want more features or a GUI
such as https://github.com/Grovkillen/ESP_Easy_Flasher

Git Clone or download the esptool_wrapper.ps1 script to your PC, ensuring that the two
dependencies mentioned above have already been met. You should already be able to call
both the dependencies from a command line and see their help:

```
> esptool.py
esptool.py v4.7.0
usage: esptool [-h] <etc>
```
```
> plink
 Plink: command-line connection utility
 Release 0.80
 Usage: plink [options] [user@]host [command] <etc>
```
Obviously esptool.py has a dependency on Python being installed.

Before running, edit the esptool_wrapper.ps1 in any text editor and change the path
to the directory where you want to upload / download your ESP32 flash ROMs, for eg:

```
$Path = "D:\Flash ROMs"
```
```
$Path = "C:\esp32\myproject\roms"
```

Then save the script before running it
