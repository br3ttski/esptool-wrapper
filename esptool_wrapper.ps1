# NOTE this script works best when run directly in PowerShell (not PowerShell ISE)
# It has two dependencies on utilities that must already be installed on your PC
# 1. Espressif ESPtool.py - https://github.com/espressif/esptool
# Git clone and run setup.py to install esptool.py into Environment:Path
# 2. Putty PLink - https://www.chiark.greenend.org.uk/%7Esgtatham/putty/latest.html
# Download the MSI installer of Putty and it will install putty link (PLink) too.
# My test environment is a Windows 10 PC, your mileage may vary on other OSes.
# This script is intended to make using esptool more pleasant, not handling all the
# possible things it does. There are other tools if you want more features or a GUI
# such as https://github.com/Grovkillen/ESP_Easy_Flasher

# Environment
$Activities      = @("Read Flash ID","Read Flash to bin","Verify Flash","Write Flash (verified)","Erase Flash","Open Com Port (with Plink)","Exit")
$AfterActivities = @("Do nothing (default)","Soft Reset","Hard Reset")
$BaudRate        = "921600"
$FlashSizes      = @("1MB","2MB","4MB","8MB","16MB")
$Path            = "D:\Flash ROMs"

function DefineBaudRate {
    $BaudRates = @("9600","19200","38400","57600","115200","460800","921600")
    Write-Host "Set baud rate to:" -Fore Green
    $i = 1
    foreach($Rate in $BaudRates){
        Write-Host "$i. $Rate"
        $i++
        }

    $i = Read-Host "Enter a choice"; $i = $i -1
    $BaudRate = $BaudRates[$i]
}
function DefineBIN      {
    $filenames = @(Get-ChildItem $Path -Filter "*.bin" | Out-GridView -Title 'Choose a file' -PassThru)
    $BinFileName = $filenames[0] | Select -ExpandProperty Name
    $BinFilePath = $Path + "\" + $BinFileName
}
function DefineNewBin   {
    $BinFileName = Read-Host "Enter a filename for the bin"
    $BinFilePath = $Path + "\" + $BinFileName
}
function DefineCommPort {
    $lptAndCom = '{4d36e978-e325-11ce-bfc1-08002be10318}'
    $ComPorts = @(get-wmiobject -Class win32_pnpentity | where ClassGuid -eq $lptAndCom | Select -ExpandProperty name)
    $ComPort = $ComPorts | Out-GridView -Title 'Choose a com port' -PassThru
    $ComPort = $ComPort -replace '.*\(' -replace '\).*'
}
function DefineMB       {
    $SizeSelected = $false
    while(!$SizeSelected){
        Clear; Sleep 1
        Write-Host "Size of flash ROM (check flash ID)" -Fore Green
        $i = 1
        foreach($Size in $FlashSizes){
            Write-Host "$i. $Size"
            $i++
            }

        $case = $null
        $case = Read-Host "Enter a choice"

        switch($case){
            1       {$BinSize = "0x100000" ;$SizeSelected = $true}
            2       {$BinSize = "0x200000" ;$SizeSelected = $true}
            3       {$BinSize = "0x400000" ;$SizeSelected = $true}
            4       {$BinSize = "0x800000" ;$SizeSelected = $true}
            5       {$BinSize = "0xF00000" ;$SizeSelected = $true}
            default {Write-Host "Whoops... try again"; Sleep 1}
        }
    }
}
function DefineStart    {
    Clear; Sleep 1
    $StartOffset = $null
    Write-Host "Start offset of flash ROM (advanced)" -Fore Green
    $StartOffset = Read-Host "Enter a start offset byte (safe default: 0)"
    if($StartOffset -eq $null -or $StartOffset -eq ""){$StartOffset = "0"}
}
function EraseFlash     {$Activity = "erase_flash"}
function ExecuteCmd     {& esptool.py -p $ComPort -b $BaudRate --after $After $Activity}
function OpenComPort    {. DefineBaudRate; & plink -serial $ComPort -sercfg $BaudRate,8,n,1,X}
function ReadFlashID    {$Activity = "flash_id"}
function ReadFlashToBIN {. DefineNewBIN; . DefineStart; . DefineMB; . WarnProgress; `
                         $Activity = @("read_flash", $StartOffset, $BinSize, $BinFilePath)}
function SelectActivity {
    $ActivitySelected = $false
    while(!$ActivitySelected){
        Clear; Sleep 1
        Write-Host "ESPTool.py on $ComPort @ $Baudrate" -Fore Gray
        Write-Host "Available activities" -Fore Green
        $i = 1
        foreach($Activity in $Activities){
            Write-Host "$i. $Activity"
            $i++
            }
        
        $case = $null
        $case = Read-Host "Enter a choice"

        switch($case){
            1       {. ReadFlashID    ;$ActivitySelected = $true}
            2       {. ReadFlashToBIN ;$ActivitySelected = $true}
            3       {. VerifyFlash    ;$ActivitySelected = $true}
            4       {. WriteFlash     ;$ActivitySelected = $true}
            5       {. EraseFlash     ;$ActivitySelected = $true}
            6       {. OpenComPort    ;$ActivitySelected = $true}
            7       {  $exit     =     $ActivitySelected = $true}
            default {Write-Host "Whoops... try again"; Sleep 1}
        }
    }
}
function SelectDoAfter  {
    $ActivitySelected = $false
    while(!$ActivitySelected){
        Clear; Sleep 1
        Write-Host "Activity selected is: $Activity" -Fore Green
        Write-Host "After interacting with the board:"
        $i = 1
        foreach($After in $AfterActivities){
            Write-Host "$i. $After"
            $i++
            }

        $case = $null
        $case = Read-Host "Enter a choice"
        
        switch($case){
            1       {$After = "no_reset"  ;$ActivitySelected = $true}
            2       {$After = "soft_reset";$ActivitySelected = $true}
            3       {$After = "hard_reset";$ActivitySelected = $true}
            default {$After = "no_reset"  ;$ActivitySelected = $true}
        }
    }
}
function VerifyFlash    {. DefineBIN; . DefineStart; $Activity = @("verify_flash", $StartOffset , $BinFilePath)}
function WarnProgress   {
    Write-Host "The esptool's real progress is not shown. Wait a minute or two before cancelling" -Fore Red
}
function WriteFlash     {. DefineBIN; . DefineStart; $Activity = @("write_flash",  $StartOffset , $BinFilePath)}

$exit = $false
. DefineCommPort

while(!$exit){
    . SelectActivity
    if(!$exit){
    . SelectDoAfter
    . ExecuteCmd
    Pause
    }
}
