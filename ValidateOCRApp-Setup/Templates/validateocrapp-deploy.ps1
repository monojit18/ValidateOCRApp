param([Parameter(Mandatory=$false)] [string] $rg,      
      [Parameter(Mandatory=$false)] [string] $fpath,
      [Parameter(Mandatory=$true)]  [string] $deployFileName,
      [Parameter(Mandatory=$false)] [string] $appName,
      [Parameter(Mandatory=$false)] [string] $storageAccountName,
      [Parameter(Mandatory=$true)]  [string] $vnetName)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/$deployFileName.json" `
-appName $appName -storageAccountName $storageAccountName `
-vnetName $vnetName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/$deployFileName.json" `
-appName $appName -storageAccountName $storageAccountName `
-vnetName $vnetName
