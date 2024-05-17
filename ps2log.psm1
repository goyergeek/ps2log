##################### Private Functions and Classes, Not Exported. #####################

class ps2logConfig {
    static [string] $Name = "Default"
    static [string] $ConfigPath = "$env:APPDATA\ps2log"
    static [string] $LogPath = "$env:APPDATA\ps2log\Logs"
    static [Int] $MaxFiles = 10
    static [Int] $MaxFileSizeMB = 10
    static [bool] $ArchiveLogs = $false
    static [Int] $MaxArchiveFiles = 100
    static [Int] $LogLevel = 1     ### 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    hidden [string] $ConfigVersion = "1.05172024b"
    hidden [guid] $ConfigID = [guid]::NewGuid()
    hidden [datetime] $Created = $(Get-Date)
    hidden [datetime] $Modified = $(Get-Date)

    ps2logConfig(
        [string] $Name,
        [string] $ConfigPath,
        [string] $LogPath,
        [Int] $MaxFiles,
        [Int] $MaxFileSizeMB,
        [bool] $ArchiveLogs,
        [Int] $MaxArchiveFiles,
        [Int] $LogLevel
        ) {
        $this.Name = $Name
        $this.ConfigPath = $ConfigPath
        $this.LogPath = $LogPath
        $this.MaxFiles = $MaxFiles
        $this.MaxFileSizeMB = $MaxFileSizeMB
        $this.ArchiveLogs = $ArchiveLogs
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2logConfig(
        [string] $ConfigPath,
        [string] $LogPath,
        [Int] $MaxFiles,
        [Int] $MaxFileSizeMB,
        [bool] $ArchiveLogs,
        [Int] $MaxArchiveFiles,
        [Int] $LogLevel
        ) {
        $this.ConfigPath = $ConfigPath
        $this.LogPath = $LogPath
        $this.MaxFiles = $MaxFiles
        $this.MaxFileSizeMB = $MaxFileSizeMB
        $this.ArchiveLogs = $ArchiveLogs
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2logConfig(
        [string] $LogPath,
        [Int] $MaxFiles,
        [Int] $MaxFileSizeMB,
        [bool] $ArchiveLogs,
        [Int] $MaxArchiveFiles,
        [Int] $LogLevel
        ) {
        $this.LogPath = $LogPath
        $this.MaxFiles = $MaxFiles
        $this.MaxFileSizeMB = $MaxFileSizeMB
        $this.ArchiveLogs = $ArchiveLogs
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2logConfig(
        [Int] $MaxFiles,
        [Int] $MaxFileSizeMB,
        [bool] $ArchiveLogs,
        [Int] $MaxArchiveFiles,
        [Int] $LogLevel
        ) {
        $this.MaxFiles = $MaxFiles
        $this.MaxFileSizeMB = $MaxFileSizeMB
        $this.ArchiveLogs = $ArchiveLogs
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2logConfig(
        [Int] $MaxFileSizeMB,
        [bool] $ArchiveLogs,
        [Int] $MaxArchiveFiles,
        [Int] $LogLevel
        ) {
        $this.MaxFileSizeMB = $MaxFileSizeMB
        $this.ArchiveLogs = $ArchiveLogs
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2logConfig([bool] $ArchiveLogs, [Int] $MaxArchiveFiles, [Int] $LogLevel) {
        $this.ArchiveLogs = $ArchiveLogs
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2logConfig([Int] $MaxArchiveFiles, [Int] $LogLevel) {
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2logConfig([Int] $LogLevel) {
        $this.LogLevel = $LogLevel
    }

    ps2logConfig() {
    
    }

    
    ps2logConfig([hashtable]$info){
        switch ($info.Keys){
            'Name'              {$this.name = $info.Name}
            'ConfigPath '       {$this.ConfigPath = $info.ConfigPath}
            'LogPath'           {$this.LogPath = $info.LogPath}
            'MaxFiles'          {$this.MaxFiles = $info.MaxFiles}
            'MaxFileSizeMB'     {$this.MaxFileSizeMB = $info.MaxFileSizeMB}
            'ArchiveLogs'       {$this.ArchiveLogs = $info.ArchiveLogs}
            'MaxArchiveFiles'   {$this.MaxArchiveFiles = $info.MaxArchiveFiles}
            'LogLevel'          {$this.LogLevel = $info.LogLevel}
        }
    }
    
    [void] Write([string]$type) {

        if(!(Test-Path "$($this.ConfigPath)")){
            New-Item -Path "$($this.ConfigPath)" -ItemType Directory -Force
        }
        
        switch($type.ToLower()) {
            'xml'{
                [xml]$configData = @"
<?xml version="1.0" encoding="utf-8"?>
<ps2logConfigs type=`"ps2log`" version=`"$($this.ConfigVersion)`">
`t<Config ID=`"$($this.ConfigID)`" Created=`"$($this.Created)`" Modified=`"$($this.Modified)`">
`t`t<ConfigPath>$($this.ConfigPath)</ConfigPath>
`t`t<LogPath>$($this.LogPath)</LogPath>
`t`t<MaxFiles>$($this.MaxFiles)</MaxFiles>
`t`t<MaxFileSizeMB>$($this.MaxFileSizeMB)</MaxFileSizeMB>
`t`t<ArchiveLogs>$($this.ArchiveLogs)</ArchiveLogs>
`t`t<MaxArchiveFiles>$($this.MaxArchiveFiles)</MaxArchiveFiles>
`t`t<LogLevel>$($this.LogLevel)</LogLevel>
`t</Config>
</ps2logConfigs>
"@
                [xml]$configData.Save("$($this.ConfigPath)\ps2logConfig.xml")
            }
            'csv' {Write-Host "This should write a CSV File"}
            'tab' {Write-Host "This should write a TSV file"}
        }
            
    }

    [void] Append([ps2logConfig]$configObj){
        
    }

} # End Of Class ps2logConfig


# dtStamp - helper function that does the obvious.
function dtStamp {
    param (
        [Parameter(Mandatory=$false,ValueFromPipeLine=$True,Position=0)]
        [ValidateSet(1,2)]
        [Int] $stampType
    )
    $FileDate = Get-Date -Format "MMddyyyyHHmmss"
    $LogDate = Get-Date -Format "MM/dd/yyyy HH:mm:ss:ffff"
    if ($stampType -eq 1) {
        return $FileDate
    } else {
        return $LogDate
    }
} # End Of dtStamp Function

##################### End Of Private Functions. #####################



##################### Public Cmdlets #####################

<#
    # ps2logConfig (new,set,get)
    # New - Generate New PSCustomObject to contain config information
    # Get - Get config information from a pre-made file
    # Set - Change config settings and write to file.
#>

# New-ps2logConfig
# Creates a new ps2log configuration file at the specified path.
function New-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false,ValueFromPipeLine=$True,Position=0)]
        [string] $Name= "Default",

        [Parameter(Mandatory=$false,ValueFromPipeLine=$True,Position=1)]
        [string] $path= "C:$($env:HOMEPATH)\ps2log\config",

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=2)]
        [string] $Logpath= "C:$($env:HOMEPATH)\ps2log\logs",

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=3)]
        [ValidateRange(10,100)]
        [int] $MaxFiles = 10,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=4)]
        [ValidateRange(10,50)]
        [int] $MaxFileSizeMB = 20,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=5)]
        [ValidateSet({$true,$false})]
        [bool] $ArchiveLogs = $True,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=6)]
        [ValidateRange(10,100)]
        [int] $MaxArchiveFiles = 10,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=7)]
        [ValidateSet(1,2,3)]
        [int] $LogLevel = 1  ## 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    )

    # Begin: Process Parameters into Object
    Begin {
        
        $configObj = [PSCustomObject]@{
            Name = [string] "Default"
            CreatedDate = [string] $(dtStamp)
            LastModified = [string] $(dtStamp)
            Path = "$path\ps2logConf.xml"
            LogPath = [string]$LogPath
            MaxFiles = [int]$MaxFiles
            MaxFileSizeMB = [int]$MaxFileSizeMB
            ArchiveLogs = [bool]$ArchiveLogs
            MaxArchiveFiles = [int]$MaxArchiveFiles
            LogLevel = [int]$LogLevel
        }
    }

    Process {
        
        if(!(Test-Path $path)){
            New-Item $path -ItemType Directory -Force | Out-Null
        }
    }

    End {

        Write-Output $configObj
    }
    
} # End Of New-ps2logConfig Function

# Set-ps2logConfig
# Set one or more attributes for a ps2log configuration file at the specified path.
function Set-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeLine=$True,Position=0)]
        [string] $path,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=1)]
        [string] $Logpath,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=2)]
        [ValidateRange({10,100})]
        [int] $MaxFiles,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=3)]
        [ValidateRange({10,50})]
        [int] $MaxFileSizeMB,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=4)]
        [ValidateSet({$true,$false})]
        [bool] $ArchiveLogs,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=5)]
        [ValidateRange({10,100})]
        [int] $MaxArchiveFiles,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=6)]
        [ValidateSet({1,2,3})]
        [int] $LogLevel  ## 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    )

    # Begin: Process Parameters into Object
    Begin {
        if(!(Test-Path "$path\ps2log.config")){
            Write-Host "The path for filename are invalid, please try again."
        }
        $configObj = [PSCustomObject]@{
            Path = "$path\ps2log.config"
            LogPath = [string]$LogPath
            MaxFiles = [int]$MaxFiles
            MaxFileSizeMB = [int]$MaxFileSizeMB
            ArchiveLogs = [bool]$ArchiveLogs
            MaxArchiveFiles = [int]$MaxArchiveFiles
            LogLevel = [int]$LogLevel
            CreatedDate = [string] $(dtStamp 1)
            LastModified = [string] $(dtStamp 1)
        }
    }

    Process {
        $configObj | Out-File "$path\ps2log.config" -Force
    }

    End {
        Write-Output $configObj
    }
    
} # End Of New-ps2logConfig Function

# Get-ps2logConfig
# Fetches the ps2log configuration file from the specified location
fucntion Get-ps2logConfig {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true,Position=0)]
        [ValidateScript({Test-Path $_})]
        [string] $path
    )
    
    begin {
        if(!($path)){
            exit(1)
        }
    }

    process {
        $ps2logConfig = Get-Content "$path\ps2logConfig.txt"
    }

    end {
        Write-Output $ps2logConfig
    }

} # End Of Get-ps2logConfig Function

# Write-PS2Log - Takes Log Object, Configuration File, and Writes logs to relavent channels based on content.
function Write-PS2Log {
    param (
        [Parameter(Mandatory=$True,ValueFromPipeLine=$true,Position=0)]
        [ValidateScript({
            if(!($_.GetType().Name -eq "PSCustomObject")){
                $msg = "ERROR: Input for logger must be of type PSCustomObject. Function will exit!"
                exit($msg)
            }

            if(!($_.lType -and $_.msgObj)) {
                $msg = "ERROR: One or more of the input object properties is not defined or null. Function will exit!"
                exit($msg)
            }

        })]
        [PSCustomObject] $logObj
    )

    return [PSCustomObject] $logObj
} # End Of Function