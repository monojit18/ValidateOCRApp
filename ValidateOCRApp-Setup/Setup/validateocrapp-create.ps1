param([Parameter(Mandatory=$false)] [string] $resourceGroup = "appservice-workshop-rg",
      [Parameter(Mandatory=$false)] [string] $subscriptionId = "6bdcc705-8db6-4029-953a-e749070e6db6",
      [Parameter(Mandatory=$false)] [string] $baseFolderPath = "/Users/monojitdattams/Development/Projects/Serverless_Projects/C#_Sources/ValidateOCRApp/ValidateOCRApp-Setup/")

$templatesFolderPath = $baseFolderPath + "/Templates"
$functionDeployCommand = "/validateocrapp-deploy.ps1 -rg $resourceGroup -fpath $templatesFolderPath"

# # PS Logout
# Disconnect-AzAccount

# # PS Login
# Connect-AzAccount

# # PS Select Subscriotion 
# Select-AzSubscription -SubscriptionId $subscriptionId

$functionDeployPath = $templatesFolderPath + $functionDeployCommand
Invoke-Expression -Command $functionDeployPath