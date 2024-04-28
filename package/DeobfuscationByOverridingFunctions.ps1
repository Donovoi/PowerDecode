<#
Function name: DeobfuscateByOverriding
Description: Receives a script as input and performs de-obfuscation by cmdlet overriding.   
Function calls: IsCompressed, IsEncoded, BitmapFetch, Deobfuscator, UpdateLog
Input: $ObfuscatedScript
Output: $DeobfuscationOutput
#>
function DeobfuscateByOverriding {
    param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript , 
		
		[Parameter(
			Mandatory = $False)]
           $Timeout
	)

  
#Initialize
$IEX = ((gc "package\overrides\Invoke-Expression.txt") |Out-String);
$AddType =  ((gc "package\overrides\Add-Type.txt") |Out-String);
$NewObject =  ((gc "package\overrides\New-Object.txt") |Out-String);
$NewItem =  ((gc "package\overrides\New-Item.txt") |Out-String);
$Other  = ((gc "package\overrides\Other.txt") |Out-String);

$IEX >  ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")
$AddType > ([System.IO.Path]::GetTempPath() +"Add-Type.txt")
$NewObject >  ([System.IO.Path]::GetTempPath() +"New-Object.txt")
$NewItem >  ([System.IO.Path]::GetTempPath() +"New-Item.txt")
$Other  >  ([System.IO.Path]::GetTempPath() +"Other.txt")

$ObfuscatedScript |Out-File ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")

#Deobfuscating selector
if ($ObfuscatedScript -match "VirtualAlloc") {
 
 Write-Host "VirtualAlloc found!" -ForegroundColor blue
 
$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv AddType  ((gc ([System.IO.Path]::GetTempPath() +"Add-Type.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String));
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ 
sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);
sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv AddType).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value)));}
else { sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv AddType).value)+((gv Other).value)+((gv ObfuscatedScript).value)));}
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
((gv -name "error").value)> ([System.IO.Path]::GetTempPath() +"local_errors.txt")
"@

UpdateLog ("[DeobfuscateByOverriding]: VirtualAlloc found! Deobfuscation command built:  "+$Deobfuscating);
}

else {

      if( IsCompressed $ObfuscatedScript){

         Write-Host "Compressed format recognized" -ForegroundColor magenta 

$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String));
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ 
sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);
sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value)));}
else {sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv ObfuscatedScript).value)));}
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
((gv -name "error").value)> ([System.IO.Path]::GetTempPath() +"local_errors.txt")
"@  

UpdateLog ("[DeobfuscateByOverriding]: Compressed format recognized, deobfuscation command built:  "+$Deobfuscating);
       }

       else {

               if( IsEncoded $ObfuscatedScript ){

                    Write-Host "Encoded format recognized" -ForegroundColor cyan
                   
$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String)); 
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ 
sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);
sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value)));}
else { sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv ObfuscatedScript).value)));}
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
((gv -name "error").value)> ([System.IO.Path]::GetTempPath() +"local_errors.txt")
"@

UpdateLog ("[DeobfuscateByOverriding]: Encoded format recognized, deobfuscation command built:  "+$Deobfuscating);

                }
			
			    else {

                        if( BitmapFetch $ObfuscatedScript ){
							
							Write-Host "Code fetch from bitmap image detected" -ForegroundColor black -BackgroundColor green
$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String));
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){
sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);
sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value)));}
else { sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv ObfuscatedScript).value)));}
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
((gv -name "error").value)> ([System.IO.Path]::GetTempPath() +"local_errors.txt")
"@

UpdateLog ("[DeobfuscateByOverriding]: Code fetch from bitmap image detected, deobfuscation command built:  "+$Deobfuscating);
							
						} 
						
						else {

$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv NewObject  ((gc ([System.IO.Path]::GetTempPath() +"New-Object.txt")) |Out-String);
sv NewItem  ((gc ([System.IO.Path]::GetTempPath() +"New-Item.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String)); 
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ 
sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);
sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv NewObject).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value)));}
else { sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv NewObject).value)+((gv Other).value)+((gv ObfuscatedScript).value)));}
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
((gv -name "error").value)> ([System.IO.Path]::GetTempPath() +"local_errors.txt")
"@

UpdateLog ("[DeobfuscateByOverriding]: Default deobfuscation command built:  "+$Deobfuscating);
                               
						}  
                }
        }

 	
}  

$DeobfuscationOutput = Deobfuscator $Deobfuscating  $Timeout
UpdateLog ("[DeobfuscateByOverriding]: Deobfuscation output:  "+$DeobfuscationOutput);

Remove-Item  ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")
Remove-Item  ([System.IO.Path]::GetTempPath() +"Add-Type.txt")
Remove-Item  ([System.IO.Path]::GetTempPath() +"New-Object.txt")
Remove-Item  ([System.IO.Path]::GetTempPath() +"New-Item.txt")
Remove-Item  ([System.IO.Path]::GetTempPath() +"Other.txt")


 return $DeobfuscationOutput
 
}

<#
Function name: Deobfuscator
Description: Takes a deobfuscating instruction string as input and locally executes them  based on the specified timeout. Deobfuscation output is returned
Function calls: UpdateLog
Input:  $Deobfuscating , $Timeout
Output: $DeobfuscationOutput
#>
function Deobfuscator {
     param(
        [Parameter(
			Mandatory = $True)]
        $Deobfuscating,
		
		[Parameter(
			Mandatory = $False)]
        $Timeout
	)
         
		$CommandFile = ([System.IO.Path]::GetTempPath() +"DeobfuscationCommand.ps1");
        $Deobfuscating | Out-File $CommandFile
		
		UpdateLog ("[Deobfuscator]: Deobfuscation command loaded from:  "+$CommandFile);
            
	    $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessStartInfo.FileName = "powershell"
        $ProcessStartInfo.CreateNoWindow = $true
        $ProcessStartInfo.RedirectStandardError = $false
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
		$ProcessStartInfo.Arguments = "-File $($CommandFile)"
     
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessStartInfo
        
        $Process.Start() | Out-Null
		
		#timeout
		$t= [int] $Timeout
		if(-not $Process.WaitForExit($t*1000)){
            Write-Host "Execution stopped after "$t" seconds due timeout" -ForegroundColor red
			UpdateLog ("[Deobfuscator]: Execution stopped after "+$t+" seconds due timeout");
			Stop-Process $Process
			
			$TmpFile = ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
            if (Test-Path $TmpFile ){
                Remove-Item $TmpFile 
            }
        }
	
	$DeobfuscationOutput = ""
	if ( Test-Path ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt") ) {
		$DeobfuscationOutput =  (Get-Content ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")) |Out-String
		Remove-Item ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
	}
	if(Test-Path $CommandFile){
		Remove-Item $CommandFile
	}
	$LocalErrors = ""
	if ( Test-Path ([System.IO.Path]::GetTempPath() +"local_errors.txt") ) {
		$LocalErrors = (Get-Content ([System.IO.Path]::GetTempPath() +"local_errors.txt"))|Out-String
		Remove-Item ([System.IO.Path]::GetTempPath() +"local_errors.txt")
	}
	
	UpdateLog ("[Deobfuscator]: Local execution errors:  "+$LocalErrors);
	
	return $DeobfuscationOutput
}

<#
Function name: ExecString
Description: Takes a string as input and returns its execution output
Function calls: EncodeBase64 , DecodeBase64 
Input:  $String
Output: $ExecutionOutput
#>
function ExecString {
     param(
        [Parameter(
			Mandatory = $True)]
        $String
	)
            
	$StringBase64 =  EncodeBase64 $String
	
	
	    $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessStartInfo.FileName = "powershell"
        $ProcessStartInfo.CreateNoWindow = $true
        $ProcessStartInfo.RedirectStandardError = $false
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
		
		
		if($StringBase64.length -le 8000){
            $ProcessStartInfo.Arguments = "-EncodedCommand $($StringBase64)"
        }
        else{
            
            $TmpFile = [System.IO.Path]::GetTempPath() + [GUID]::NewGuid().ToString() + ".ps1"; 
           
            DecodeBase64($StringBase64 ) | Out-File $TmpFile 
            $ProcessStartInfo.Arguments = "-File $($TmpFile)"
        }
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessStartInfo
        
        $Process.Start() | Out-Null
				
		if(-not $Process.WaitForExit(10000)){     
            Stop-Process $Process     
        }
		
		if ($TmpFile -and (Test-Path $TmpFile )){
            Remove-Item $TmpFile 
        }
        
        $ExecutionOutput = $Process.StandardOutput.ReadToEnd()
        						
    return $ExecutionOutput
}

<#
Function name: HiddenProcessDetect
Description: Receives a script as input and detects whether it uses System.Diagnostics.Process to run a hidden process
Function calls: -
Input:  $Script
Output: $true/$false
#>
function HiddenProcessDetect {
        param(
            [Parameter(Mandatory=$True, Valuefrompipeline = $True)]
            [string]$Script 
        )
	$Pattern = [regex] "\[system\.diagnostics\.process\]\:\:start"
    $Matches = $Pattern.match($Script.toLower() )
	
	if($Matches.value ) {
		return $true
	}
	else {
		return $false
	}
}

<#
Function name: ResolveHiddenProcess
Description: Receives a script as input and discovers the hidden process it executes
Function calls: -
Input:  $Script
Output: $OutputCode
#>
function ResolveHiddenProcess {
        param(
            [Parameter(Mandatory=$True, Valuefrompipeline = $True)]
            [string]$Script 
        )
	
$regex=@"
\[[Ss][Yy][Ss][Tt][Ee][Mm]\.[Dd][Ii][Aa][Gg][Nn][Oo][Ss][Tt][Ii][Cc][Ss]\.[Pp][Rr][Oo][Cc][Ee][Ss][Ss]\]\:\:[Ss][Tt][Aa][Rr][Tt]
"@

$pattern = [regex] $regex
$matches = $pattern.matches($Script)

foreach ($match in $matches) { 
$replace = "[System.Diagnostics.Process]::null; ReturnProcessStartArguments "
$Script = $Script.replace($match , $replace)
}

$ReturnProcessStartArguments = (get-content package\ReturnProcessStartArguments.txt)|Out-String

$CodeToExec = "sv ErrorActionPreference 'silentlycontinue';"+"`n"+$ReturnProcessStartArguments+"`n"+$Script

$OutputCode=""
if (GoodSyntax  $CodeToExec ) {			
	$OutputCode = ExecString $CodeToExec  
}

else {
	Write-Host "Cannot solve hidden process layer due syntax errors" -ForegroundColor red
}

#remove "-command" flag from output code
$CommandFlagRegex = "\-[Cc]([Oo]{0,1}[Mm]{0,2}[Aa]{0,1}[Nn]{0,1}[Dd]{0,1})(\s+)(.+)"
$CommandFlagPattern = [regex] $CommandFlagRegex
$CommandFlagMatches = $CommandFlagPattern.matches($OutputCode)

foreach ($match in $CommandFlagMatches) {
	$OutputCode = $match.value -replace '\-[Cc]([Oo]{0,1}[Mm]{0,2}[Aa]{0,1}[Nn]{0,1}[Dd]{0,1})' , ''
}

return $OutputCode
	
}