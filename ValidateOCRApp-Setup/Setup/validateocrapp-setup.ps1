param([Parameter(Mandatory=$true)] [string] $resourceGroup = "<resource_group>",
      [Parameter(Mandatory=$true)] [string] $subscriptionId = "<subscription_id>",      
      [Parameter(Mandatory=$true)] [string] $keyVaultName = "<keyvault_name>",      
      [Parameter(Mandatory=$true)] [string] $vnetName = "srvless-workshop-vnet",
      [Parameter(Mandatory=$true)] [string] $vnetPrefix = "190.0.0.0/20",        
      [Parameter(Mandatory=$true)] [string] $subnetName = "srvless-workshop-subnet",
      [Parameter(Mandatory=$true)] [string] $subNetPrefix = "190.0.0.0/24",
      [Parameter(Mandatory=$true)] [string] $kvTemplateFileName = "keyvault-deploy",
      [Parameter(Mandatory=$true)] [string] $networkTemplateFileName = "network-deploy",
      [Parameter(Mandatory=$true)] [string] $functionTemplateFileName = "validateocrapp-deploy",
      [Parameter(Mandatory=$true)] [string] $appName = "<app_name>",
      [Parameter(Mandatory=$true)] [string] $storageAccountName = "<storageAccount_Name>",
      [Parameter(Mandatory=$true)] [string] $objectId = "<object_Id>",
      [Parameter(Mandatory=$true)] [string] $baseFolderPath = "<folder_path>")

$templatesFolderPath = $baseFolderPath + "/Templates"
$keyvaultDeployCommand = "/KeyVault/$kvTemplateFileName.ps1 -rg $resourceGroup -fpath $templatesFolderPath -deployFileName $kvTemplateFileName -keyVaultName $keyVaultName -objectId $objectId"

$networkNames = "-vnetName $vnetName -vnetPrefix $vnetPrefix -subnetName $subnetName -subNetPrefix $subNetPrefix"
$networkDeployCommand = "/Network/$networkTemplateFileName.ps1 -rg $resourceGroup -fpath $templatesFolderPath -deployFileName $networkTemplateFileName $networkNames"

$functionDeps = "-appName $appName -storageAccountName $storageAccountName"
$functionDeployCommand = "/validateocrapp-deploy.ps1 -rg $resourceGroup -fpath $templatesFolderPath -deployFileName $functionTemplateFileName $functionDeps"

# PS Select Subscription 
Select-AzSubscription -SubscriptionId $subscriptionId

$vnetDisconnectCommand = "az webapp vnet-integration remove --name $appName --resource-group $resourceGroup"
Invoke-Expression -Command $vnetDisconnectCommand

$slotNamesList = @("Dev", "QA")
foreach ($slotName in $slotNamesList)
{
      $appSlotName = $appName + "/" + $slotName
      $vnetDisconnectCommand = "az webapp vnet-integration remove --name $appName --resource-group $resourceGroup -s $appSlotName"
      Invoke-Expression -Command $vnetDisconnectCommand

}

 Network deploy
$networkDeployPath = $templatesFolderPath + $networkDeployCommand
Invoke-Expression -Command $networkDeployPath

#  KeyVault deploy
$keyvaultDeployPath = $templatesFolderPath + $keyvaultDeployCommand
Invoke-Expression -Command $keyvaultDeployPath

#  Function deploy
$functionDeployPath = $templatesFolderPath + $functionDeployCommand
Invoke-Expression -Command $functionDeployPath

foreach ($slotName in $slotNamesList)
{
      $appSlotName = $appName + "/" + $slotName
      $vnetIntCommand = "az webapp vnet-integration add --name $appName --resource-group $resourceGroup --subnet $subnetName --vnet $vnetName -s $appSlotName"
      Invoke-Expression -Command $vnetIntCommand

}

