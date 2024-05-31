##################### Private Classes, Functions, Variables #####################
$ver = "1.0.5172024b"
# Class ps2LogConfig - 
# Holds all configuration information needed for the ps2Log Logger Cmdlets.
class ps2LogConfig {
    [string] $Name = "Default"
    [string] $ConfigPath = "$env:APPDATA\ps2log"
    [string] $LogPath = "$env:APPDATA\ps2log\Logs"
    [Int] $MaxFiles = 10
    [Int] $MaxFileSizeMB = 10
    [bool] $ArchiveLogs = $false
    [Int] $MaxArchiveFiles = 100
    [Int] $LogLevel = 1     ### 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    hidden [string] $ConfigVersion = $ver
    hidden [guid] $Guid = [guid]::NewGuid().Guid
    hidden [datetime] $Created = $(Get-Date)
    hidden [datetime] $Modified = $(Get-Date)

    ps2LogConfig() {
        Write-Verbose "Default Configuration object created:"
        Write-Verbose ($this.Name)
        Write-Verbose ($this.ConfigPath)
        Write-Verbose ($this.LogPath)
        Write-Verbose ($this.MaxFiles)
        Write-Verbose ($this.MaxFileSizeMB)
        Write-Verbose ($this.ArchiveLogs)
        Write-Verbose ($this.MaxArchiveFiles)
        Write-Verbose ($this.LogLevel)
        Write-Verbose ($this.ConfigVersion)
        Write-Verbose ($this.Guid)
        Write-Verbose ($this.Created)
        Write-Verbose ($this.Modified)
    }


    ps2LogConfig([hashtable]$info){
        switch ($info.Keys){
            'Name'              {$this.name = $info.Name}
            'ConfigPath'        {$this.ConfigPath = $info.ConfigPath}
            'LogPath'           {$this.LogPath = $info.LogPath}
            'MaxFiles'          {$this.MaxFiles = $info.MaxFiles}
            'MaxFileSizeMB'     {$this.MaxFileSizeMB = $info.MaxFileSizeMB}
            'ArchiveLogs'       {$this.ArchiveLogs = $info.ArchiveLogs}
            'MaxArchiveFiles'   {$this.MaxArchiveFiles = $info.MaxArchiveFiles}
            'LogLevel'          {$this.LogLevel = $info.LogLevel}
            'ConfigVersion'     {$this.ConfigVersion = $info.ConfigVersion}
            'Guid'              {$this.Guid = $info.Guid}
            'Created'           {$this.Created = $info.Created}
            'Modified'          {$this.Modified = $info.Modified}
        }
    }

    ps2LogConfig([xml]$xmlObj){
        Write-Host "Something happens here"
        
        [array]$Configs = $xmlObj.ps2LogConfigs.Config 


    }
    
    [void] Save([ps2LogConfig[]]$ps2LogConfigs, [string]$Path) {

        if($Path){
            foreach($ps2LogConfig in $ps2LogConfigs){
                $this.ConfigPath = $Path
            }
            $this.ConfigPath = $Path
        }

        if(!(Test-Path "$($this.ConfigPath)")){
            New-Item -Path "$($this.ConfigPath)" -ItemType Directory -Force
        }

        [xml]$xml = (getXmlFromConfigs $ps2LogConfigs)
        $xml.Save("$($this.ConfigPath)\ps2LogConfig.xml")

    }

    [void] Append([ps2LogConfig]$configObj){

    }

    [ps2LogConfig[]] Load([string]$Path) {
        [xml]$xml = Get-Content $this.ConfigPath
        [array]$configs = (getConfigsFromXml $xml)

        return [ps2LogConfig[]]$configs
    } # End Of Function Load

} # End Of Class ps2LogConfig

class ps2LogConfigList {
    # Static Property to hold the list of ps2LogConfig Objects
    static [System.Collections.Generic.List[ps2LogConfig]] $ps2LogConfigs

    # Static method to initialize the list of ps2LogConfig Objects.  Called in the other
    # static methods to avoid needing to explicitly initialize the value.
    static [void] Initialize(){[ps2LogConfigList]::Initialize($false)}
    static [bool] Initialize([bool]$force) {
        if ([ps2LogConfigList]::ps2LogConfigs.Count -gt 0 -and -not $force) {
            return $false
        }

        [ps2LogConfigList]::ps2LogConfigs = [System.Collections.Generic.List[ps2LogConfig]]::new()

        return $true
    }
    
    

    # Ensure a ps2LogConfig Object is valid for the list
    static [void] Validate([ps2LogConfig]$ps2LogConfig){
        $Prefix = @(
            'ps2LogConfig Validation failed: Configuration Object must be defined' 
            'with all required properties, but'
        ) -join ' '
        if($null -eq $ps2LogConfig) {throw "$Prefix object instance was null"}
        if([string]::IsNullOrEmpty($ps2LogConfig.Name)) {throw "$Prefix Name was not defined"}
        if([string]::IsNullOrEmpty($ps2LogConfig.ConfigPath)) {throw "$Prefix ConfigPath was not defined"}
        if([string]::IsNullOrEmpty($ps2LogConfig.LogPath)) {throw "$Prefix LogPath was not defined"}
        if([datetime]::IsNullOrEmpty($ps2LogConfig.Created)) {throw "$Prefix Created was not defined"}
        if([datetime]::IsNullOrEmpty($ps2LogConfig.Modified)) {throw "$Prefix Modified was not defined"}
        if([int]::IsNullOrEmpty($ps2LogConfig.LogLevel)) {throw "$Prefix LogLevel was not defined"}
        if([int]::IsNullOrEmpty($ps2LogConfig.MaxFiles)) {throw "$Prefix MaxFiles was not defined"}
        if([int]::IsNullOrEmpty($ps2LogConfig.MaxFileSizeMB)) {throw "$Prefix MaxFileSizeMB was not defined"}
        if([int]::IsNullOrEmpty($ps2LogConfig.MaxArchiveFiles)) {throw "$Prefix MaxArchiveFiles was not defined"}
        if([bool]::IsNullOrEmpty($ps2LogConfig.ArchiveLogs)) {throw "$Prefix ArchiveLogs was not defined"}
    }

    static [void] Add([ps2LogConfig]$ps2LogConfig){
        [ps2LogConfigList]::Initialize()
        [ps2LogConfigList]::Validate($ps2LogConfig)
        if([ps2LogConfigList]::ps2LogConfigs.Contains($ps2LogConfig)){
            throw "Configuration $($ps2LogConfig) already exists in this list."
        }

        $FindPredicate = {
            param([ps2LogConfig]$p)

            $p.Name -eq $ps2LogConfig.Name -or
            $b.guid -eq $ps2LogConfig.guid
        }.GetNewClosure()
        if([ps2LogConfigList]::ps2LogConfigs.Find($FindPredicate)) {
            throw "ps2LogConfig: '$($ps2LogConfig.Name)' or guid:$($ps2LogConfig.guid) already exists in the list"
        }

        [ps2LogConfigList]::ps2LogConfigs.Add($ps2LogConfig)
    }

    # Clear the list of Configurations
    static [void] Clear() {
        [ps2LogConfigList]::Initialize()
        [ps2LogConfigList]::ps2LogConfigs.Clear()
    }

    # Find a specific Configuration in the list
    static [ps2LogConfig] Find([scriptblock]$Predicate){
        [ps2LogConfigList]::Initialize()
        return [ps2LogConfigList]::ps2LogConfigs.Find($Predicate)
    }

}


# 

# dtStamp - helper function that returns dates in string formats.
function dtStamp {
    param (
        [Parameter(Mandatory=$false,ValueFromPipeLine=$True,Position=0)]
        [ValidateSet(1,2)]
        [switch] $File
    )
    $FileDate = Get-Date -Format "MMddyyyyHHmmss"
    $LogDate = Get-Date -Format "MM/dd/yyyy HH:mm:ss:ffff"
    
    if ($File) {
        return $FileDate
    } 
    
    return $LogDate
    
} # End Of dtStamp Function



# getConfigSplat -  Returns a hastable comprised of parameter inputs for use in building ps2LogConfig objects.
#                   This function currently only operates from within ps2LogConfig Cmdlets.
function getHashTblFromParams{
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,Position=0)]
        [string] $CommandName
    )
    
    Write-Verbose "Executing function getHashTblFromParams for $CommandName"
    $ParameterList = (Get-Command -Name $CommandName).Parameters
    

    $ps2LogParams = ($ParameterList.Values | 
        Select-Object * | 
        Where-Object{($_.ParameterSets.Keys -eq "ps2log")}
    )
    
    Write-Verbose "Keys to Process: $($ps2LogParams.Name -join ",")"

    [hashtable] $hashTbl = @{}
    [bool] $defaultObject = $true

    foreach($arg in $ps2LogParams.Name) {
        Write-Verbose "Checking value for Key: $arg"
        $a = (Get-Variable -Name $arg -ErrorAction SilentlyContinue).Value
        if($a){
            $defaultObject = $false
            $hashTbl.Add($arg,$a)
            Write-Verbose "Value for variable found adding to splat: {$arg : $a}"
        }
    }
    if($defaultObject){Write-Verbose "No bound parameters found, default object created."}
    
    foreach($key in $hashTbl.Keys){
        Write-Verbose "$key : $($hashTbl["$key"])" 
    }
    
    return [hashtable] $hashTbl
} # End Of Function getHashTblFromParams

function getConfigsFromXml{
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,Position=0)]
        [xml] $Xml,
        
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true,Position=1)]
        [srting] $CommandName
    )
    
    Write-Verbose "Executing function getConfigsfromXml for $CommandName"
    if(!($xml.ps2LogConfigs.version -eq $ver)){Write-Warning "Log File version does not match Module Version! Configuration may fail!"}
    [array]$configs = $xml.ps2LogConfigs.Config
    $keyList = ($configs[0] | Get-Member -Force | Where-Object{$_.MemberType -eq 'Property'}).Name
    Write-Verbose "Keys to process: $($keyList -join ",")"
    [array]$configs = ($xml.ps2LogConfigs.Config)
    Write-Verbose "Configuration Count in file: $($configs.Count)"

    [ps2LogConfig[]]$ps2LogConfigs = @{}
    

    foreach($ps2LogConfig in $ps2LogConfigs){
        Write-Verbose "Building ps2LogConfig Object for $($config.Name)"
        [hashtable] $hashTbl = @{}
        foreach($key in $keyList) {
            $hashTbl.Add($key,$config.$key)
        }

        foreach($key in $hashTbl.Keys){
            Write-Verbose "$key : $($hashTbl["$key"])" 
        }

        $ps2LogConfigs += [ps2LogConfig]::new($hashTbl)

    }
    
    return [array] $ps2LogConfigs
} # End Of Function getConfigsFromXml

function getXmlFromConfigs{
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [array]$ps2LogConfigs
    )

    function tl([int]$int){return "`t" * $int}
    [string]$xmlString = ""
    $filter = @("Guid","ConfigVersion")
    [array]$elementList = ($this | Get-Member -Force | Where-Object {$_.MemberType -eq "Property" -and $filter -notcontains $_.Name}).Name
    $header1 = "<?xml version=`"1.0`" encoding=`"utf-8`"?>`n"
    $header2 = "<ps2LogConfigs type=`"ps2log`" version=`"$($this.ConfigVersion)`">`n"
    $configClose = "$(tl 1)</Config>`n"
    $footer = "</ps2LogConfigs>"
    [string]$xmlString += $header1,$header2

    foreach($ps2LogConfig in $ps2LogConfigs){
        $configOpen = "$(tl 1)<Config Name=`"$($this.Name)`" Guid=`"$($this.Guid)`">`n"
        $xmlString += $configOpen
        foreach($element in $elementList){
            $configElement = "$(tl 2)<$($element)>$($this.$element)</$($element)>`n"
            $xmlString += $configElement
        }
        $xmlString += $configClose
    }

    $xmlString += $footer
    [xml]$xmlConfig = $xmlString
    return [xml]$xmlConfig
    #[xml]$xmlConfig.Save("$($this.ConfigPath)\ps2LogConfig.xml")
}

function handleInputObject {
    param (
        [ps2LogConfig] $inputObject,
        [hashtable] $hash
    )

    
}

function updateModified(){
    $this.Modified = (Get-Date)
}


##################### End Of Private Functions. #####################



##################### Public Cmdlets #####################

<#
    # ps2LogConfig (new,set,get)
    # New - Instantiate an instance of ps2LogConfig Object
    # Get - Get config information from a location
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
        [string] $ConfigPath,

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
        Write-Verbose "Executing: $CommandName"
        
        
    }

    Process {

        Write-Verbose "$CommandName | Generate hash table"
        $hashTbl = (getHashTblFromParams $CommandName)

        Write-Verbose "$CommandName | Create new ps2LogConfig Object"
        [ps2LogConfig[]]$configObj = [ps2LogConfig]::new($hashTbl)
              
    }

    End {

        Write-Output $configObj[0]
    }
    
} # End Of New-ps2LogConfig Cmdlet

Function Out-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName="ps2Log")]
        [ValidateScript({$_.GetType().Name -eq 'ps2LogConfig'})]
        [ps2LogConfig[]] $Config,

        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateScript({Test-Path $_})]
        [string] $Path

    )

    Begin {

        $CommandName = $PSCmdlet.MyInvocation.InvocationName
        Write-Verbose "Executing: $CommandName"


    }

    Process {
        
        $Config[0].Save($Config, $Path)

    }

    End {
        Write-Output $configs
    }
} # End of Write-ps2LogConfig Cmdlet


Function Get-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName="ps2Log")]
        [ValidateScript({Test-Path $_})]
        [string] $Path,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string] $Name

    )

    Begin {

        [xml]$ps2LogConfig = Get-Content $Path


    }

    Process {
        [array]$configs = (getConfigsFromXml $ps2LogConfig)
        
        if($Name){
            $configs = $configs | Where-Object {$_.Name -eq $Name}
        }

    }

    End {
        Write-Output $configs
    }
}

function Set-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$True,ParameterSetName="ps2logObjLoader")]
        [ValidateScript({$_.GetType().Name -eq "ps2LogConfig"})]
        [ps2LogConfig] $InputObject,

        [Parameter(Mandatory=$false,ValueFromPipeline=$True,ParameterSetName="ps2logObjLoader")]
        [ValidateScript({Test-Path $_})]
        [string]$ConfigFile,

        [Parameter(Mandatory=$false,ValueFromPipeline=$True,ParameterSetName="ps2logObjSetter")]
        [ValidateScript({$_.GetType().Name -eq "hashtable"})]
        [hashtable]$hashtable,

        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
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

        
    }

    Process {
        if($inputObject){
            # Do some Shit here
        }

        if($hashtable){
            $
        }

        $hashTbl = (getHashTblFromParams $CommandName)
        $configObj = [ps2LogConfig]::new($hashTbl)
        
        if($InputObject) {

        }
    }

    End {

        Write-Output $configObj
    }
    
} # End Of Set-ps2LogConfig Cmdlet