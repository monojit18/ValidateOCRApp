param([Parameter(Mandatory=$true)] [string] $rg = "<resource_group>",
        [Parameter(Mandatory=$true)] [string] $fpath = "<folder_opath>",
        [Parameter(Mandatory=$true)] [string] $keyVaultName = "<key_vault_name>",
        [Parameter(Mandatory=$true)] [string] $objectId = "<object_id>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/keyvault-deploy.json" `
-keyVaultName $keyVaultName -objectId $objectId

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/keyvault-deploy.json" `
-keyVaultName $keyVaultName -objectId $objectId