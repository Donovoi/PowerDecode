<#
Function name: ExtractUrls
Description: Receives a text as input and returns an array containing all urls detected  
Function calls: -
Input: $Data
Output: $Urls  
#>
function ExtractUrls() {
	param(
        [Parameter( Mandatory = $True)] [string]$Data
    )
		
	$UrlList = New-Object System.Collections.Generic.List[System.Object]
			
	$UrlPattern = [regex]  "(http[s]?|[s]?ftp[s]?)(:\/\/)(.*?)(\""|\'|\}|\@|\,|\s|\*|\?)"	
	$UrlMatches = $UrlPattern.matches($Data)
		
	foreach($group in $UrlMatches.Groups) {
		if($group.Name -eq 0) {
			$url = $Group.Value
			$url = $url.SubString(0, $Url.Length - 1)
			$url = $url.replace(" ","").replace("`n","").replace("`r","")
			$UrlList.add( $url )
		}
	}
		
	return $UrlList
}

<#
Function name: UrlHttpResponseCheck
Description: Receives a url as input and returns the associated http response status code  
Function calls: ConvertHexStringToByteArray UpdateReport
Input: $Url
Output: $UrlInfo 
#>
function UrlHttpResponseCheck() {
	param([Parameter(Mandatory = $True)] [string]$Url
    )
	
	sv ErrorActionPreference 'SilentlyContinue'
	
	try {
	$HttpRequest = [System.Net.WebRequest]::Create($Url)
    $HttpResponse = $HttpRequest.GetResponse()
	}
	catch [Net.WebException] {
     $HttpResponse = $_.Exception.Response
     $HttpStatus = [int]$HttpResponse.StatusCode       
		
	}
	$HttpStatus = [int]$HttpResponse.StatusCode
		
switch ( $HttpStatus ) {
		
    101 {$Info ="[101: Switching Protocols] - "; Break}
    200 {$Info ="[200: Url is Active] - " ; Break }
    201 {$Info ="[201: Created] - " ; Break }
    202 {$Info ="[202: Accepted] - " ; Break }
	204 {$Info ="[204: No Content] - "; Break}
    301 {$Info ="[301: Moved Permanently] - " ; Break }
    302 {$Info ="[302: Found] - " ; Break }
    304 {$Info ="[304: Not Modified] - " ; Break }
	400 {$Info ="[400: Bad Request] - "; Break}
    401 {$Info ="[401: Unauthorized] - " ; Break }
    403 {$Info ="[403: Forbidden] - " ; Break }
    404 {$Info ="[404: Not Found] - " ; Break }
    405 {$Info ="[405: Method not Allowed] - "; Break}
    406 {$Info ="[406: Not Acceptable] - " ; Break }
    407 {$Info ="[407: Proxy Authentication Required] - " ; Break }
    415 {$Info ="[415: Unsupported Media Type] - " ; Break }
	422 {$Info ="[422: Unprocessable Entity] - "; Break}
    500 {$Info ="[500: Internal Server Error] - " ; Break }
    503 {$Info ="[503: Service Unavailable] - " ; Break }
	504 {$Info ="[504: Gateway Timeout] - " ; Break }
    default {$Info = "[ "+$HttpStatus+" ] Cannot connect to: " ; Break }
	
}

$UrlInfo = $Info + " "  + $Url  	

sv ErrorActionPreference 'Continue'

return  $UrlInfo   	
}