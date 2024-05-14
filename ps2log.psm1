##################### Private Functions, Not Exported. #####################

# dtStamp - helper function that does the obvious.
function dtStamp {
    param (
        [Parameter(Mandatory=$True,ValueFromPipeLine=$True,Position=0)]
        [ValidateSet(1,2)]
        [Int] $stampType
    )
    [datetime] $FileDate = Get-Date -Format "MMDDYYYY-HHmmss"
    [datetime] $LogDate = Get-Date -Format "MM\dd\yyyy HH:mm:ss:ffff"
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
        [string] $path= "$($env:HOMEPATH)\ps2log\config",

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=1)]
        [string] $Logpath= "$($env:HOMEPATH)\ps2log\logs",

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=2)]
        [ValidateRange({10..100})]
        [int] $MaxFiles = 10,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=3)]
        [ValidateRange({10..50})]
        [int] $MaxFileSizeMB = 20,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=4)]
        [ValidateSet({$true,$false})]
        [bool] $ArchiveLogs = $True,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=5)]
        [ValidateRange({10..100})]
        [int] $MaxArchiveFiles = 10,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=6)]
        [ValidateSet({1,2,3})]
        [int] $LogLevel = 1  ## 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    )

    # Begin: Process Parameters into Object
    Begin {
        if(!(Test-Path $path)){
            New-Item $path -ItemType Directory -Force
        }
    }

    Process {
        $configObj = [PSCustomObject]@{
            Path = "$path\ps2log.config"
            LogPath = [string]$LogPath
            MaxFiles = [int]$MaxFiles
            MaxFileSizeMB = [int]$MaxFileSizeMB
            ArchiveLogs = [bool]$ArchiveLogs
            MaxArchiveFiles = [int]$MaxArchiveFiles
            LogLevel = [int]$LogLevel
            ConfigDate = [string] $(dtStamp 1)
        }

        $configObj | Out-File "$path\ps2log.config" -Force
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
        [ValidateRange({10..100})]
        [int] $MaxFiles,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=3)]
        [ValidateRange({10..50})]
        [int] $MaxFileSizeMB,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=4)]
        [ValidateSet({$true,$false})]
        [bool] $ArchiveLogs,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=5)]
        [ValidateRange({10..100})]
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