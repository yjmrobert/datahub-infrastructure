
param(
    $Environment       = "dev",
    $Location          = "Canada Central"
    )
    
$TemplateName = "state";
$DestinationPath   = "$PSScriptRoot\..\terraform\$Environment\$TemplateName";


# Run the terraform plan and apply scripts
Write-Output "Running terraform init, plan, and destroy"
terraform -chdir="$DestinationPath" init
terraform -chdir="$DestinationPath" plan -destroy -out="$DestinationPath\destroy-plan.out"
terraform -chdir="$DestinationPath" apply "$DestinationPath\destroy-plan.out"

# Clean up and delete the state directory
Write-Output "Cleaning up state directory"
Remove-Item -Path "$DestinationPath" -Force -Recurse -ErrorAction SilentlyContinue