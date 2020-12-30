param([Parameter(Mandatory=$true)]   [string] $rg,
        [Parameter(Mandatory=$true)] [string] $fpath,
        [Parameter(Mandatory=$true)] [string] $deployFileName,
        [Parameter(Mandatory=$true)] [string] $vnetName,
        [Parameter(Mandatory=$true)] [string] $vnetPrefix,
        [Parameter(Mandatory=$true)] [string] $subnetName,
        [Parameter(Mandatory=$true)] [string] $subnetPrefix)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/Network/$deployFileName.json" `
-vnetName $vnetName -vnetPrefix $vnetPrefix `
-subnetName $subnetName -subnetPrefix $subnetPrefix

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/Network/$deployFileName.json" `
-vnetName $vnetName -vnetPrefix $vnetPrefix `
-subnetName $subnetName -subnetPrefix $subnetPrefix