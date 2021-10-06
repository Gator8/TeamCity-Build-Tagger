# Read in arguments from build step
$buildId = $args[0]
$tcUrl = $args[1]

# Parse arguments to extract the TeamCity server name/IP and the TeamCity port
$x,$a,$port = $tcUrl.split(':')
$y,$w,$server = $a.split('/')

#$port
#$server

# run through list of commits for the build and parse out Jira tickets that can be found
function Get-ChangeLog {
  if($buildId -ne 0) {
    $changeList = {@()}.Invoke()
    $baseUrl   = "http://$server`:$port"
    $changesUrl = "$baseUrl/guestAuth/app/rest/changes?locator=build`:(id`:$buildId)"

    [xml] $changesDoc = Invoke-WebRequest -Uri $changesUrl -UseBasicParsing
    $changesDoc.SelectNodes("//changes/change") | % {

      $changeUrl = "$baseUrl$($_.href)"
      [xml] $changeDoc = Invoke-WebRequest -Uri $changeUrl -Headers $changesHeader -UseBasicParsing

	  if(($($changeDoc.change.comment).Contains("FEATURE-"))) {
		$startstr = ($($changeDoc.change.comment).IndexOf("FEATURE-"))
		$idnum = $idnum -replace "[^a-zA-Z0-9]"
		$idnum = ($($changeDoc.change.comment)).SubString($startstr+8,4)
		$idnum = "FEATURE-"+$idnum
		$changeList.Add($idnum.TrimEnd())
	  }elseif(($($changeDoc.change.comment).Contains("DEV-"))) {
		$startstr = ($($changeDoc.change.comment).IndexOf("DEV-"))
		$idnum = ($($changeDoc.change.comment)).SubString($startstr+4,4)
		$idnum = $idnum -replace "[^a-zA-Z0-9]"
		$idnum = "DEV-"+$idnum
		$changeList.Add($idnum.TrimEnd())	  
	  }elseif(($($changeDoc.change.comment).Contains("BUG-"))) {
		$startstr = ($($changeDoc.change.comment).IndexOf("BUG-"))
		$idnum = ($($changeDoc.change.comment)).SubString($startstr+4,4)
		$idnum = $idnum -replace "[^a-zA-Z0-9]"
		$idnum = "BUG-"+$idnum
		$changeList.Add($idnum.TrimEnd())
	  }else {
	   #nothing
	  }	  
    }
    $changeList
  } else {
    @(" * Change list is not available")
  }
}

$lastBuildDate = Get-ChangeLog

$BldTagList = @()
$BldTagList = $lastBuildDate -split "`r`n"
$BldTagList = $BldTagList | select -Unique

$EntireStringContents = '& curl.exe -v -s -S -o nul --basic --user USER:PASSWORD --request POST --header "Content-Type: application/xml" --data "'

# Create array of tags to include
if($BldTagList.Count -gt 1) {
	#Loop array
	$dstring = "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?><tags>"
	For($i=0; $i -lt $BldTagList.length; $i++) {
		$dstring = $dstring + "<tag name='" + $BldTagList[$i] + "'/>"
	}
	$dstring = $dstring + "</tags>"	
}else{
	$dstring = "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?><tags><tag name='$BldTagList'/></tags>"
}

# Write tags back to TeamCity Server
$EntireStringContents = $EntireStringContents + $dstring +'" "http://'+$server+':'+$port+'/httpAuth/app/rest/builds/id:'+$buildId+'/tags/"'
#$EntireStringContents
Invoke-Expression $EntireStringContents
