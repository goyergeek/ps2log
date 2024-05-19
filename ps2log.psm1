##################### Private Functions and Classes, Not Exported. #####################

class ps2LogConfig {
    [string] $Name = "Default"
    [string] $ConfigPath = "$env:APPDATA\ps2log"
    [string] $LogPath = "$env:APPDATA\ps2log\Logs"
    [Int] $MaxFiles = 10
    [Int] $MaxFileSizeMB = 10
    [bool] $ArchiveLogs = $false
    [Int] $MaxArchiveFiles = 100
    [Int] $LogLevel = 1     ### 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    hidden [string] $ConfigVersion = "1.05172024b"
    hidden [guid] $ConfigID = [guid]::NewGuid()
    hidden [datetime] $Created = $(Get-Date)
    hidden [datetime] $Modified = $(Get-Date)

    ps2LogConfig() {}

    ps2LogConfig([hashtable]$info){
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
    
    ps2LogConfig(
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

    ps2LogConfig(
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

    ps2LogConfig(
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

    ps2LogConfig(
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

    ps2LogConfig(
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

    ps2LogConfig([bool] $ArchiveLogs, [Int] $MaxArchiveFiles, [Int] $LogLevel) {
        $this.ArchiveLogs = $ArchiveLogs
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2LogConfig([Int] $MaxArchiveFiles, [Int] $LogLevel) {
        $this.MaxArchiveFiles = $MaxArchiveFiles
        $this.LogLevel = $LogLevel
    }

    ps2LogConfig([Int] $LogLevel) {
        $this.LogLevel = $LogLevel
    }
    
    [void] Save([string]$type) {

        if(!(Test-Path "$($this.ConfigPath)")){
            New-Item -Path "$($this.ConfigPath)" -ItemType Directory -Force
        }
        
        switch($type.ToLower()) {
            'xml'{
                [xml]$configData = @"
<?xml version="1.0" encoding="utf-8"?>
<ps2LogConfigs type=`"ps2log`" version=`"$($this.ConfigVersion)`">
`t<Config ID=`"$($this.ConfigID)`" Created=`"$($this.Created)`" Modified=`"$($this.Modified)`">
`t`t<ConfigPath>$($this.ConfigPath)</ConfigPath>
`t`t<LogPath>$($this.LogPath)</LogPath>
`t`t<MaxFiles>$($this.MaxFiles)</MaxFiles>
`t`t<MaxFileSizeMB>$($this.MaxFileSizeMB)</MaxFileSizeMB>
`t`t<ArchiveLogs>$($this.ArchiveLogs)</ArchiveLogs>
`t`t<MaxArchiveFiles>$($this.MaxArchiveFiles)</MaxArchiveFiles>
`t`t<LogLevel>$($this.LogLevel)</LogLevel>
`t</Config>
</ps2LogConfigs>
"@
                [xml]$configData.Save("$($this.ConfigPath)\ps2LogConfig.xml")
            }
            'csv' {Write-Host "This should write a CSV File"}
            'tab' {Write-Host "This should write a TSV file"}
        }
            
    }

    [void] Append([ps2LogConfig]$configObj){

    }

} # End Of Class ps2LogConfig


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
    # ps2LogConfig (new,set,get)
    # New - Generate New PSCustomObject to contain config information
    # Get - Get config information from a pre-made file
    # Set - Change config settings and write to file.
#>

# New-ps2LogConfig
# Creates a new ps2log configuration file at the specified path.
function New-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param (   
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string] $Name,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string] $Path,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string] $Logpath,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateRange(10,100)]
        [int] $MaxFiles,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateRange(10,50)]
        [int] $MaxFileSizeMB,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [switch] $ArchiveLogs,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateRange(10,100)]
        [int] $MaxArchiveFiles,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateSet(1,2,3)]
        [int] $LogLevel     ## 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    )

    # Begin: Process Parameters into Object
    Begin {

        # Collect relevant parameter names for ps2logConfig constructor
        $CommandName = $PSCmdlet.MyInvocation.InvocationName
        Write-Verbose "Starting Constructor for command: $CommandName"
        $ParameterList = (Get-Command -Name $CommandName).Parameters
        

        $ps2LogParams = ($ParameterList.Values | 
            Select-Object * | 
            Where-Object{($_.ParameterSets.Keys -eq "ps2log")}
        )
        
        [hashtable]$configSplat = @{}
        
    }

    Process {

        # Generate the Config Splat and object based on provided parameters
        foreach($arg in $ps2LogParams.Name) {
            Write-Verbose "Processing Variable for Key: $arg"
            $a = (Get-Variable -Name $arg -ErrorAction SilentlyContinue).Value
            if($a){
                $configSplat.Add($arg,$a)
                Write-Verbose "Value for variable found adding to splat: {$arg : $a}"
            }
        }
                
        $configObj = [ps2LogConfig]::new($configSplat)
        
    }

    End {

        Write-Output $configObj
    }
    
} # End Of New-ps2LogConfig Cmdlet

function Set-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$True,ParameterSetName="ps2logObj")]
        [ValidateScript({$_.GetType().Name -eq "ps2LogConfig"})]
        [ps2LogConfig] $configObj,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string] $Name,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string] $Path,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string] $Logpath,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateRange(10,100)]
        [int] $MaxFiles,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateRange(10,50)]
        [int] $MaxFileSizeMB,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [switch] $ArchiveLogs,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateRange(10,100)]
        [int] $MaxArchiveFiles,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateSet(1,2,3)]
        [int] $LogLevel     ## 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    )

    # Begin: Process Parameters into Object
    Begin {

        # Collect relevant parameter names for ps2logConfig constructor
        $CommandName = $PSCmdlet.MyInvocation.InvocationName
        Write-Verbose "Starting Constructor for command: $CommandName"
        $ParameterList = (Get-Command -Name $CommandName).Parameters
        

        $ps2LogParams = ($ParameterList.Values | 
            Select-Object * | 
            Where-Object{($_.ParameterSets.Keys -eq "ps2log")}
        )
        
        [hashtable]$configSplat = @{}
        
    }

    Process {

        # Generate the Config Splat and object based on provided parameters
        foreach($arg in $ps2LogParams.Name) {
            Write-Verbose "Processing Variable for Key: $arg"
            $a = (Get-Variable -Name $arg -ErrorAction SilentlyContinue).Value
            if($a){
                $configSplat.Add($arg,$a)
                Write-Verbose "Value for variable found adding to splat: {$arg : $a}"
            }
        }
                
        $configObj = [ps2LogConfig]::new($configSplat)
        
    }

    End {

        Write-Output $configObj
    }
    
} # End Of Set-ps2LogConfig Cmdlet