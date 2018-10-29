
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

#log Variable und function

$Logfile = "c:\Choco.log"
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

######################## packages to install#######################

$Packages = '7zip', 'firefox', 'notepadplusplus','googlechrome','adobereader'

###################################################################

#install packages und report to log at 
ForEach ($PackageName in $Packages)
 {
    choco install $PackageName -y
    if (-not $?){ 
    $time=Get-Date
         Logwrite "[$time]: the Package $PackageName is NOT Installed"
     }
}

powercfg.exe -x -monitor-timeout-ac 0
powercfg.exe -x -monitor-timeout-dc 0
powercfg.exe -x -disk-timeout-ac 0
powercfg.exe -x -disk-timeout-dc 0
powercfg.exe -x -standby-timeout-ac 0
powercfg.exe -x -standby-timeout-dc 0
powercfg.exe -x -hibernate-timeout-ac 0
powercfg.exe -x -hibernate-timeout-dc 0

#Set-OSCPowerButtonAction –Action Shutdown

sc.exe config wuauserv start=disabled

# display the status of the service
sc.exe query wuauserv

# stop the service, in case it is running
sc.exe stop wuauserv

#add members Printer Brother HL-L8350CDW

$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$driverpath=$directorypath +'\Brother HL-L8350CDW series\BROCH13A.INF'
Pnputil.exe /add-driver $driverpath /install

Add-PrinterPort -Name "192.168.50.19" -PrinterHostAddress "192.168.50.19"
add-printerdriver -Name "Brother HL-L8350CDW series"
Add-Printer -Name "Brother HL-L8350CDW" -DriverName "Brother HL-L8350CDW series" -PortName "192.168.50.19"

#office rearm
"C:\Program Files (x86)\Microsoft Office\Office16\OSPPREARM.EXE"

cscript.exe "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs" /rearm

cscript.exe "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs" /rearm


#VGA treiber installieren

$MB=Get-CimInstance Win32_BaseBoard | Select-Object  Product
if($MB.product -match "NUC")
{
    Write-Host "nuc vga install"
    $nucvga="\\nas00.gfu.net\disk2\Treiber\Intel-NUC-Kit-NUC7i5DNKE_Win10-64_Drivers.20180803\nuc7i7dn-win10-64bit-inf\GFX_WIN64_24.20.100.6194\Graphics\igdlh64.inf"
    Pnputil.exe /add-driver $nucvga /install
} else
{
    # H6 VGA Driver
    $h6vga="\\nas00.gfu.net\disk2\Treiber\_Schulung_PC_H6\NVIDIA Grafikkarte\64bit\win7_winvista\NV_DISP.inf"
    Pnputil.exe /add-driver $h6vga /install
    $h6vga1="\\nas00.gfu.net\disk2\Treiber\_Schulung_PC_H6\NVIDIA Grafikkarte\64bit\win7_winvista\NVDD.inf"
    Pnputil.exe /add-driver $h6vga1 /install

    #H1 VGA driver
    $h1vga="\\nas00.gfu.net\disk2\Treiber\_Schulung_PC_H1\mb_driver_vga_intel_64_8series\Graphics\igdlh64.inf"
    Pnputil.exe /add-driver $h1vga /install
}
 #set computer icon on desktop
     #Registry key path
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    #Property name
    $name = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    #check if the property exists
    $item = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
    if($item)
    {
        #set property value
        Set-ItemProperty  -Path $path -name $name -Value 0 
    }
    Else
    {
        #create a new property
        New-ItemProperty -Path $path -Name $name -Value 0 -PropertyType DWORD  | Out-Null 
    }
