##################### Module Environment Variable #####################
Param(
    [Parameter(Mandatory=$false,Position=0)]
    [string]$Path = "C:\PS2Log"
)

if($env:PS2Log -ne $Path){
    $env:PS2Log = $Path
}


if(!($env:PS2Log)){
    [System.Environment]::SetEnvironmentVariable('PS2Log',"$Path",'User')
}

##################### Private Classes, Functions, Variables #####################
$ver = "1.0.5172024b"
# Class ps2LogConfig - 
# Holds all configuration information needed for the ps2Log Logger Cmdlets.
class ps2LogConfig {
    static [string] $Version = $ver
    [ValidateNotNullOrEmpty()][string] $Name = "Default"
    [ValidateNotNullOrEmpty()][string] $LogPath = "$env:PS2Log\Logs"
    [ValidateRange(10,100)][Int32] $MaxFiles = 10
    [ValidateRange(10,50)][Int32] $MaxFileSizeMB = 10
    [bool] $Enabled = $true
    [bool] $ArchiveLogs = $false
    [ValidateRange(10,100)][Int32] $MaxArchiveFiles = 100
    [ValidateRange(1,3)][Int32] $LogLevel = 1     ### 1 = INFO, 2 = WARN, 3 = DEBUG (All logs contain error stacks)
    hidden [guid] $Guid = [guid]::NewGuid().Guid
    hidden [datetime] $Created = $(Get-Date)
    hidden [datetime] $Modified = $(Get-Date)
    
    ps2LogConfig() {
        
        Write-Verbose "[ps2LogConfig] | Constructor | Default | Return: Default Class Instance"
        
    }


    ps2LogConfig([hashtable]$info){
        Write-Verbose "[ps2LogConfig] | Constructor | HashTable | Start : Process Table"
        switch ($info.Keys){
            'Name'              {$this.name = $info.Name}
            'LogPath'           {$this.LogPath = $info.LogPath}
            'MaxFiles'          {$this.MaxFiles = $info.MaxFiles}
            'MaxFileSizeMB'     {$this.MaxFileSizeMB = $info.MaxFileSizeMB}
            'Enabled'           {$this.Enabled = $info.Enabled}
            'ArchiveLogs'       {$this.ArchiveLogs = $info.ArchiveLogs}
            'MaxArchiveFiles'   {$this.MaxArchiveFiles = $info.MaxArchiveFiles}
            'LogLevel'          {$this.LogLevel = $info.LogLevel}
            'ConfigVersion'     {$this.ConfigVersion = $info.ConfigVersion}
            'Guid'              {$this.Guid = $info.Guid}
            'Created'           {$this.Created = $info.Created}
            'Modified'          {$this.Modified = $info.Modified}
        }
        Write-Verbose "[ps2LogConfig] | Constructor | HashTable | End : Process Table"
        Write-Verbose "[ps2LogConfig] | Constructor | HashTable | Return : Class Instance"
    }

    ps2LogConfig([xml]$xmlObj){
        Write-Host "Something happens here"
        
        [array]$Configs = $xmlObj.ps2LogConfigs.Config 


    }
    
    [void] Save([string]$Path) {
        
        $FinalPath = "$Path\$($this.Name)-ps2LogConfig.xml"
        Write-Verbose "[ps2LogConfig]::Save(`$Path) | getXmlFromConfigs | Starting"     
        [xml]$xml = (getXmlFromConfigs -InputObject $this)
        
        if($Path){
            if(!(Test-Path "$Path")){New-Item -Path $Path -ItemType Directory -Force -Confirm}
        }
        
        $xml.Save($FinalPath)

    }

    [void] Save() {
        Write-Verbose "[ps2LogConfig]::Save() | Save XML to `$env:PS2Log | Processing"
        $FinalPath = "$env:PS2Log\$($this.Name)-ps2LogConfig.xml"
        [xml]$xml = (getXmlFromConfigs -InputObject $this)    
        if(!(Test-Path "$env:PS2Log")){New-Item -Path $env:PS2Log -ItemType Directory -Force -Confirm}
        $xml.Save($FinalPath)

    }

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
    #[string[]]$Configs = @(([ps2LogConfigList]::ps2LogConfigs.Name))
    
    

    # Ensure a ps2LogConfig Object is valid for the list
    static [void] Validate([ps2LogConfig]$ps2LogConfig){
        $Prefix = @(
            'ps2LogConfig Validation failed: Configuration Object must be defined' 
            'with all required properties, but'
        ) -join ' '
        if($null -eq $ps2LogConfig) {throw "$Prefix object instance was null"}
        if([string]::IsNullOrEmpty($ps2LogConfig.Name)) {throw "$Prefix Name was not defined"}
        if($(($ps2LogConfig.Enabled).GetType().Name) -ne "Boolean" ){throw "$Prefix Enabled was either not defined, or of the wrong type"}
        if($(($ps2LogConfig.ArchiveLogs).GetType().Name) -ne "Boolean" ){throw "$Prefix Enabled was either not defined, or of the wrong type"}
        #if([string]::IsNullOrEmpty($ps2LogConfig.ConfigPath)) {throw "$Prefix ConfigPath was not defined"}
        if([string]::IsNullOrEmpty($ps2LogConfig.LogPath)) {throw "$Prefix LogPath was not defined"}
    }

    static [void] Add([ps2LogConfig[]]$Configs){
        [ps2LogConfigList]::Initialize()
        foreach($Config in $Configs){
            [ps2LogConfigList]::Validate($Config)
            if([ps2LogConfigList]::ps2LogConfigs.Contains($Config)){
                throw "Configuration $($Config.Name): $($Config.Guid) already exists in this list."
            }

            $FindPredicate = {
                param([ps2LogConfig]$p)

                $p.Name -eq $Config.Name

            }.GetNewClosure()
            if([ps2LogConfigList]::ps2LogConfigs.Find($FindPredicate)) {
                throw "ps2LogConfig: '$($Config.Name)' or guid:$($Config.guid) already exists in the list"
            }

            [ps2LogConfigList]::ps2LogConfigs.Add($Config)
        }
    }

    # Clear the list of Configurations
    static [void] Clear() {
        [ps2LogConfigList]::Initialize()
        [ps2LogConfigList]::ps2LogConfigs.Clear()
    }

    # Find a specific Configuration in the list
    static [ps2LogConfig] Find([string]$Value){
        [ps2LogConfigList]::Initialize()
        $Index = [ps2LogConfigList]::ps2LogConfigs.FindIndex({
            param($b)
            $b.Name -eq $Value
        }.GetNewClosure())
        if($index -ge 0){
            return [ps2LogConfigList]::ps2LogConfigs[$index]
        }
        
        throw "The list did not contain a configuration item with the Name: $Value"
        
    }

    # Find every configuration matching the filtering scriptblock
    static [ps2LogConfig[]] FindAll([scriptblock]$Predicate) {
        [ps2LogConfigList]::Initialize()
        return [ps2LogConfigList]::Books.FindAll($Predicate)
    }

    # Remove a specific configuration
    static [void] Remove([ps2LogConfig]$ps2LogConfig) {
        [ps2LogConfigList]::Initialize()
        [ps2LogConfigList]::ps2LogConfigs.Remove($ps2LogConfig)
    }

    # Remove a Configuration by name or guid
    static [void] RemoveByName([string]$Value) {
        [ps2LogConfigList]::Initialize()
        $Index = [ps2LogConfigList]::ps2LogConfigs.FindIndex({
            param($b)
            $b.Name -eq $Value
        }.GetNewClosure())
        if($index -ge 0) {
            [ps2LogConfigList]::ps2LogConfigs.RemoveAt($Index)
        }
    }

    static [void] Save() {
        [ps2LogConfigList]::Initialize()
        $configXml = getXmlFromConfigs $([ps2LogConfigList]::ps2LogConfigs)
        $configXml.Save($("$env:PS2Log\ps2LogConfig.xml"))

        #### Write Shit to XML Here ####
        #### Need to go fix XML Helper Function First ####
    }
    
    [string[]] ListConfigs() {
        [string[]]$Result = [ps2LogConfigList]::ps2LogConfigs.Name -join ","
        return $Result
    }

    [ps2LogConfig[]]$Configs = $([ps2LogConfigList]::ps2LogConfigs)

    ps2LogConfigList() {


    }

} # End Of Class Ps2LogConfigList

$PS2LogConfigs = New-Object -TypeName ps2LogConfigList
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
    $VPrefix = "$CommandName | getHashTblFromParams |"
    Write-Verbose "$VPrefix Start : getHashTblFromParams."

    function bldArr(){
        Write-Verbose "$VPrefix bldArr | Start : bldArr"
        [hashtable] $hashTbl = @{}
        Write-Verbose "$VPrefix bldArr | Process : Hashtable for $Name"
        $hashTbl.Add("Name",$Name)
        foreach($arg in $ps2LogParams.Name) {
            Write-Debug "$VPrefix bldArr | Get : Value for $arg"
            $a = (Get-Variable -Name $arg -ErrorAction SilentlyContinue).Value
            if($a){
                $defaultObject = $false
                $hashTbl.Add($arg,$a)
                Write-Verbose "$VPrefix bldArr | Add : {$arg : $a}"
            }
        }
        #if($defaultObject){Write-Verbose "No bound parameters found default object created."}
        Write-Verbose "$VPrefix bldArr | Return : Hashtable"
        return $hashTbl
    }
    
    $ParameterList = (Get-Command -Name $CommandName).Parameters
    
    $ps2LogParams = ($ParameterList.Values | 
        Select-Object * | 
        Where-Object{($_.ParameterSets.Keys -eq "ps2log" -and $_.Name -ne "Name")}
    )
    
    Write-Verbose "$VPrefix Keys to Process: $($ps2LogParams.Name -join ",")"
    
    [bool] $defaultObject = $true
    [string[]]$configNames = (Get-Variable -Name Name -ErrorAction SilentlyContinue).Value
    $hashTblArr = @()

    if($configNames){ Write-Verbose "$VPrefix Configs to Process : $($configNames -join ",")" }
    if(!($configNames)){Write-Verbose "$VPrefix Configs to Process : None - Default Configuration"}

    foreach($name in $configNames){
        [hashtable] $hashTbl = (bldArr)
        $hashTblArr += $hashTbl
    }
    
    
    Write-Verbose "$VPrefix Tables to Return: $($hashTblArr.Name -Join ",")" 
    
    Write-Verbose "$VPrefix Return : Hashtable Array"
    
    return [Array] $hashTblArr
} # End Of Function getHashTblFromParams

function getConfigsFromXml{
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,Position=0)]
        [xml] $Xml,
        
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true,Position=1)]
        [string] $CommandName
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
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ParameterSetName='ps2LogConfigList')]
        [array]$ConfigList,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='ps2LogConfigObj')]
        [ps2LogConfig]$inputObject
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

    if($ConfigList){
        foreach($ps2LogConfig in $ConfigList::ps2LogConfigs){
            $configOpen = "$(tl 1)<Config Name=`"$($this.Name)`" Guid=`"$($this.Guid)`">`n"
            $xmlString += $configOpen
            foreach($element in $elementList){
                $configElement = "$(tl 2)<$($element)>$($this.$element)</$($element)>`n"
                $xmlString += $configElement
            }
            $xmlString += $configClose
        }
    }

    if($inputObject){
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



##################### Public Cmdlets, Functions, Variables #####################


<#
    # ps2LogConfig (new,get,set,add,remove,clear,save)
    # New - Instantiate an instance of ps2LogConfig
    # Get - Get config information from a file, or from $PS2LogConfigs
    # Set - Change config settings within a file, or within a ps2LogConfig in $PS2LogConfigs
    # Add - Add one or more configurations from a file or ps2LogConfig objects
    # Remove - Remove one or more configurations by name or guid from a file or from $PS2LogConfigs
#>

# New-ps2LogConfig
# Creates a new ps2log configuration file at the specified path.
function New-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string[]] $Name,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [string] $Logpath,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateRange(10,100)]
        [int] $MaxFiles,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateRange(10,50)]
        [int] $MaxFileSizeMB,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [Bool] $Enabled,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [Bool] $ArchiveLogs,

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
        $VPrefix = "$CommandName |"
        Write-Verbose "$VPrefix Start : Cmdlet Execution."
           
    }

    Process {

        Write-Verbose "$CommandName | Execute : getHashTblFromParams()"
        $hashTblarr = (getHashTblFromParams $CommandName)
        [ps2LogConfig[]]$configObj = @()

        if(!($hashTblArr)){
            Write-Verbose "$CommandName | Execute : [ps2LogConfig]::new()"
            [ps2LogConfig[]]$configObj += [ps2LogConfig]::new()
        }
        
        if($hashTblArr){
            Write-Verbose "$CommandName | Execute : [ps2LogConfig]::new()"
            foreach($hashTbl in $hashTblArr){
                
                [ps2LogConfig[]]$configObj += [ps2LogConfig]::new($hashTbl)
    
            }     
        }
    }

    End {        
        Write-Verbose "$VPrefix End : Cmdlet Execution."
        Write-Output $configObj

    }
    
} # End Of New-ps2LogConfig Cmdlet

Function Get-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ParameterSetName="ps2LogPath")]
        [ValidateScript({Test-Path $_})]
        [string[]] $Path,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2LogPath")]
        [string[]] $Name

    )

    Begin {

        $CommandName = $PSCmdlet.MyInvocation.InvocationName
        Write-Verbose "Executing: $CommandName"
           
        
        if ($Path) {
            [xml]$ps2LogConfig = Get-Content $Path
            [array]$configs = (getConfigsFromXml $ps2LogConfig $CommandName)
        }

        if(!($Path)){[array]$configs = ($PS2LogConfigs::ps2LogConfigs)}
    }

    Process {

        if($Name){[array]$configs = $configs | Where-Object {$Name -Contains $_.Name}}
        if(!($configs)){
            throw "Get-ps2LogConfig did not return any configurations with the given parameters."
        }
        
    }

    End {
        Write-Output $configs
    }
} # End of Get-ps2LogConfig

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
            Write-Verbose "Huh?  How the hell did you get here?"
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




Function Out-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName="ps2Log")]
        [ValidateScript({$_.GetType().Name -eq 'ps2LogConfig'})]
        [ps2LogConfig[]] $Config,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2Log")]
        [ValidateScript({Test-Path $_})]
        [string] $Path = $env:PS2Log

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
} # End of Out-ps2LogConfig Cmdlet

Function Add-ps2LogConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName="ps2LogObjects",Position=0)]
        [ValidateScript({$_.GetType().Name -eq 'ps2LogConfig'})]
        [ps2LogConfig[]]$InputObjects,

        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True,ParameterSetName="ps2LogXml")]
        [ValidateScript({Test-Path $_})]
        [string] $Path

    )

    Begin {

        $CommandName = $PSCmdlet.MyInvocation.InvocationName
        Write-Verbose "Executing: $CommandName"


    }

    Process {
        Foreach($Object in $InputObjects){
            $PS2LogConfigs::Add($Object)
        }

    }

    End {
        Write-Output $configs
    }
} # End of Add-ps2LogConfig Cmdlet










Export-ModuleMember -Function *-ps2LogConfig
Export-ModuleMember -Variable PS2LogConfigList, PS2LogConfigs
