# Static Configurations   ***  DO NOT CHANGE  ***



# Logger Configuration Options
$maxFiles = 10
$maxFileSize = 10   # in Megabytes
$ps2logPath = "C:\PSLogger\"    #Sets base log file location. Logs are kept per script.
#$logFormat = 1      # 1-Text, 2-CSV, 3-XMLCLI

### Private Functions, Not Exported. ###

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
} # End Of Function


### End Of Private Functions. ###

### Public Cmdlets ###

<#
    # ps2logConfig (new,get,set)
    # New - Generate New PSCustomObject to contain config information
    # Get - Get config information from a pre-made file
    # Set - Change config settings and write to file.
#>

# New-ps2logConfig
function New-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeLine=$True,Position=0)]
        [ValidateScript({Test-Path $_})]
        [string] $path,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=1)]
        [ValidateScript({Test-Path $_})]
        [string] $Logpath= "C:\Temp",

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=2)]
        [ValidateScript({Test-Path $_})]
        [int] $MaxFiles = 10,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=3)]
        [ValidateScript({Test-Path $_})]
        [int] $MaxFileSizeMB = 20,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=4)]
        [ValidateScript({Test-Path $_})]
        [bool] $ArchiveLogs = $True,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=5)]
        [ValidateScript({Test-Path $_})]
        [int] $MaxArchiveFiles = 10,

        [Parameter(Mandatory=$False,ValueFromPipeLine=$True,Position=6)]
        [ValidateScript({Test-Path $_})]
        [int] $LogLevel = 1  ## 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    )

    # Begin: Process Parameters into Object
    Begin {
        if(!($path)){
            exit(1)
        }
        $configObj = [PSCustomObject]@{
            Path = "$path\ps2log.config"
            LogPath = [string]$LogPath
            MaxFiles = [int]$MaxFiles
            MaxFileSizeMB = [int]$MaxFileSizeMB
            ArchiveLogs = [bool]$ArchiveLogs
            MaxArchiveFiles = [int]$MaxArchiveFiles
            LogLevel = [int]$LogLevel
        }
    }

    Process {
        $configObj | Out-File "$path\test.txt" -Force
    }

    End {
        return $configObj
    }
    
} # End Of Function

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


# New-PS2LogObj - Takes input parameters and returns PSCustobObject with them embedded.
function New-PS2LogObj {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,Position=0)]
        [ValidateNotNullOrEmptyAttribute()]
        [INT] $lType,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True,Position=1)]
        [ValidateNotNullOrEmptyAttribute()]
        [string] $callingScript,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True,Position=2)]
        [ValidateNotNullOrEmptyAttribute()]
        [string] $msg,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True,Position=3)]
        [ValidateNotNullOrEmptyAttribute()]
        [ArrayList] $errArray,

        [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=4)]
        [ValidateNotNullOrEmptyAttribute()]
        [xml] $customConfig
    )

    

    $logObj = [PSCustomObject]@{
        logType = $lType
        callingScript = $callingScript
        msg = $msg
        $err = $errArray
    }

    return $logObj
} # End Of Function




