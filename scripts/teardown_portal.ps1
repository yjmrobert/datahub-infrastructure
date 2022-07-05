param(
    $Environment       = "stg",
    $Location          = "Canada Central", 
    $TemplateName      = "portal",
    $DestinationPath   = "$PSScriptRoot\..\terraform\$Environment\$TemplateName"
)

# ==============================================================================
# Run the terraform plan and apply (destroy) scripts
# ==============================================================================
Write-Output "Running terraform init, plan, and destroy"
$Env:TF_IN_AUTOMATION = "true";
terraform -chdir="$DestinationPath" init -backend-config="$DestinationPath\$TemplateName.backend"
terraform -chdir="$DestinationPath" plan -destroy -out="$DestinationPath\destroy-plan.out"
terraform -chdir="$DestinationPath" apply "$DestinationPath\destroy-plan.out"

# ==============================================================================
# Clean up and delete the directory
# ==============================================================================
Write-Output "Cleaning up directory"
Remove-Item -Path "$DestinationPath" -Force -Recurse -ErrorAction SilentlyContinue
