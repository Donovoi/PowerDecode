<#
Function name: GetVariablesContent
Description: Takes a script as input and returns a list containing the variables declared by the same (name-value) 
Function calls: EncodeBase64, Declarator
Input: $Script
Output: $Variables
#>
function GetVariablesContent()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script , 
		
		[Parameter(
			Mandatory = $False)]
           $Timeout
        )

$code =@"
{
$Script
}	
"@

$AST = [System.Management.Automation.Language.Parser]::ParseInput($code, [ref]$null, [ref]$null)

$predicate = {
    param($AstObject)
    if ($AstObject -is [System.Management.Automation.Language.VariableExpressionAst]) {
        
        $parent = $AstObject.Parent
        if ($parent -is [System.Management.Automation.Language.AssignmentStatementAst] -or
            $parent -is [System.Management.Automation.Language.FunctionDefinitionAst] -or
            $parent -is [System.Management.Automation.Language.ParameterAst]) {
            return $true
        }
    }
	else{
		 if ($AstObject -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
			return $true
		}	
	}
    return $false
}

$Declarations = $ast.FindAll($predicate, $true)
$DeclarationCode = ""

$i=0
while ($i -lt $Declarations.count ) {
	if( ($Declarations[$i]).Extent.Text -match "function" ){            
		$function =  ($Declarations[$i]).Extent.Text
		
		$DeclarationCode += $function +"`n"
		
	}
	else {
		$name = ($Declarations[$i].Parent).Left.Extent.Text
		$value = ($Declarations[$i].Parent).Right.Extent.Text
		
		if( ($name.length -ne 0) -and  ($value.length -ne 0) ) {
			$DeclarationCode += $name + " = " + $value +"; `n"
		}
			
	}
	
	$i++
}

$GetUDVariables = get-content package\GetUDvariables.txt

$Arguments = "sv ErrorActionPreference 'silentlycontinue';"+"`n"+$DeclarationCode+"`n"+$GetUDvariables+"`n"+"(GetUDvariables)|Out-File ([System.IO.Path]::GetTempPath() +'DeclaredVariables.txt')"

$B64Arguments = EncodeBase64 $Arguments
$B64Arguments = "powershell -encodedcommand " + $B64Arguments

$Variables = Declarator $B64Arguments  $Timeout

return $Variables
}

<#
Function name: Declarator
Description: Takes a declarating instruction string as input and locally executes them. Declaration output is returned
Function calls: -
Input:  $Declarating, $Timeout
Output: $DeclarationOutput
#>
function Declarator() {
     param(
        [Parameter(
			Mandatory = $True)]
        $Declarating , 
		
		[Parameter(
			Mandatory = $False)]
           $Timeout
    )
         
		$CommandFile = ([System.IO.Path]::GetTempPath() +"DeclarationCommand.ps1");
        $Declarating | Out-File $CommandFile 
            
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
		$t= [int] $Timeout;
		if(-not $Process.WaitForExit($t*1000)){
            Write-Host "Execution stopped after "$t" seconds due timeout" -ForegroundColor red
			Stop-Process $Process
			
        }
	
	$DeclarationOutput = ""
	if ( Test-Path ([System.IO.Path]::GetTempPath() +"DeclaredVariables.txt") ) {
		$DeclarationOutput =  (Get-Content ([System.IO.Path]::GetTempPath() +"DeclaredVariables.txt")) |Out-String
		Remove-Item ([System.IO.Path]::GetTempPath() +"DeclaredVariables.txt")
	}
	if(Test-Path $CommandFile){
		Remove-Item $CommandFile
	}
	
	return $DeclarationOutput
}