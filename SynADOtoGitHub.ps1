param(
    [Parameter()]
    [string]$GitHubDestinationPAT,
 
    [Parameter()]
    [string]$ADOSourcePAT,
     
    [Parameter()]
    [string]$AzureRepoName,
     
    [Parameter()]
    [string]$ADOCloneURL,
     
    [Parameter()]
    [string]$GitHubCloneURL
)

# Write your PowerShell commands here.
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - -'
Write-Host ' Reflect Azure DevOps repo changes to GitHub repo'
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - - '

$stageDir = Get-Location
Write-Host "stage Dir is: $stageDir"

$githubDir = Join-Path $stageDir "gitHub"
Write-Host "github Dir: $githubDir"

$destination = Join-Path $githubDir ($AzureRepoName + ".git")
Write-Host "destination: $destination"

# Please make sure to remove 'https://' from the Azure Repo clone URL
$sourceURL = "https://$($ADOSourcePAT)@$($ADOCloneURL)"
Write-Host "source URL: $sourceURL"

# Please make sure to remove 'https://' from the GitHub Repo clone URL
$destURL = "https://$($GitHubDestinationPAT)@$($GitHubCloneURL)"
Write-Host "dest URL: $destURL"

# Check if the parent directory exists and delete
if (Test-Path -Path $githubDir) {
    Remove-Item -Path $githubDir -Recurse -Force
}

if (!(Test-Path -Path $githubDir)) {
    New-Item -ItemType Directory -Path $githubDir
    Set-Location $githubDir
    git clone --mirror $sourceURL
} else {
    Write-Host "The given folder path $githubDir already exists"
}

if (Test-Path -Path $destination) {
    Set-Location $destination
    Write-Output '*****Git removing remote secondary****'
    git remote rm secondary

    Write-Output '*****Git remote add****'
    git remote add --mirror=fetch secondary $destURL

    Write-Output '*****Git fetch origin****'
    git fetch $sourceURL

    Write-Output '*****Git push secondary****'
    git push secondary --all -f

    Write-Output '**Azure DevOps repo synced with GitHub repo**'
} else {
    Write-Host "The destination path $destination does not exist"
}

Set-Location $stageDir

if (Test-Path -Path $githubDir) {
    Remove-Item -Path $githubDir -Recurse -Force
}

Write-Host "Job completed"
