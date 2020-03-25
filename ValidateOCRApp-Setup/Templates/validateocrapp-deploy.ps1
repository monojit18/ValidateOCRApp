param([Parameter(Mandatory=$false)] [string] $rg,
      [Parameter(Mandatory=$false)] [string] $fpath)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/validateocrapp-deploy.json"

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/validateocrapp-deploy.json"
