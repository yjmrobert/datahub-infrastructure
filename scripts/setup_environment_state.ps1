
param(
    $Environment       = "dev",
    $Location          = "Canada Central"
    )
    
$TemplateName = "state";
$TemplatePath      = "$PSScriptRoot\..\terraform\templates\$TemplateName";
$DestinationPath   = "$PSScriptRoot\..\terraform\$Environment\$TemplateName";

# Run the copy_tf_template script and copy state into the environment
& $PSScriptRoot\copy_tf_template.ps1 `
    -Environment $Environment `
    -Location $Location `
    -TemplateName $TemplateName `
    -TemplatePath $TemplatePath `
    -DestinationPath $DestinationPath


# Run the terraform plan and apply scripts
Write-Output "Running terraform init, plan, and apply"
terraform -chdir="$DestinationPath" init
terraform -chdir="$DestinationPath" plan -out="$DestinationPath\plan.out"
terraform -chdir="$DestinationPath" apply "$DestinationPath\plan.out"