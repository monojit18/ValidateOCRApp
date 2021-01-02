param([Parameter(Mandatory=$false)] [string] $rg,      
      [Parameter(Mandatory=$false)] [string] $fpath,
      [Parameter(Mandatory=$true)]  [string] $deployFileName,
      [Parameter(Mandatory=$false)] [string] $appName,
      [Parameter(Mandatory=$false)] [string] $storageAccountName)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/ValidateOCRApp/$deployFileName.json" `
-appName $appName -storageAccountName $storageAccountName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/ValidateOCRApp/$deployFileName.json" `
-appName $appName -storageAccountName $storageAccountName
