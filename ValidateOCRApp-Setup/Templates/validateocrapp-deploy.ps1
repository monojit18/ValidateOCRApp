param([Parameter(Mandatory=$false)] [string] $rg,      
      [Parameter(Mandatory=$false)] [string] $fpath,
      [Parameter(Mandatory=$true)]  [string] $deployFileName,
      [Parameter(Mandatory=$false)] [string] $appName,
      [Parameter(Mandatory=$false)] [string] $storageAccountName,
      [Parameter(Mandatory=$true)]  [string] $vnetName,
      [Parameter(Mandatory=$true)]  [string] $subnetName)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/$deployFileName.json" `
-appName $appName -storageAccountName $storageAccountName `
-vnetName $vnetName -subnetName $subnetName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/$deployFileName.json" `
-appName $appName -storageAccountName $storageAccountName `
-vnetName $vnetName -subnetName $subnetName
