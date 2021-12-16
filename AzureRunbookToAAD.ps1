# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext



# Start MSGraph call for Connect-AzureAD token
Write-Output "Starting call to msgraph"

#Set Resource to MSGraph 
$resource = "?resource=https://graph.windows.net/" 
$url = $env:IDENTITY_ENDPOINT + $resource 

#Define HEADERS, pull current Identity_Header
$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
$Headers.Add("X-IDENTITY-HEADER", $env:IDENTITY_HEADER) 
$Headers.Add("Metadata", "True") 

#make a call to Identity system for msgraph token
$accessToken = Invoke-RestMethod -Uri $url -Method 'GET' -Headers $Headers

#writetoken out that way we prove we have one
Write-Output $accessToken.access_token

#Use freshly minted token for managed identity to connect to AAD
Connect-AzureAD -AadAccessToken ($accessToken.access_token) -AccountId $AzureContext.Account.Id -TenantId $AzureContext.tenant.id  #Connect to AAD

#Add Own AzureAD powershell code below, Example list all users 
Get-AzureADUser -All $true  #Retrive users from AAD

