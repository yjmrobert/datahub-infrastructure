
param(
    [Parameter(Mandatory)]
    $Environment,
    $Location = "Canada Central",
    [switch] $Destroy = $false
)
    
$TemplateName = "state";
$ProjectRoot = "$PSScriptRoot\..\..";
$TemplatePath = "$ProjectRoot\terraform\templates\$TemplateName";
$DestinationPath = "$ProjectRoot\terraform\$Environment\$TemplateName";

. $ProjectRoot\scripts\utils\copy_tf_template.ps1

# ==============================================================================
# Setup Environment
# ==============================================================================
if (!$Destroy) {

    # Check if the destination path already exists
    if (Test-Path -d $DestinationPath) {
        Write-Output "The environment state already exists. Please destroy it before running this script."
        exit 1
    }

    try {
        # Run the copy tf template script and copy state into the environment
        & Copy-Terraform-Template `
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

    }
    catch {
        Write-Output "Error: $($_.Exception.Message)"
        exit 1
    }
}

# ==============================================================================
# Destroy Environment
# ==============================================================================
else {

    # Check if the destination path exists
    if (!(Test-Path -d $DestinationPath)) {
        Write-Output "The environment state doesn't exists. Nothing to destroy."
        exit 0
    }

    try {
        # Run the terraform plan and apply (destroy) scripts
        Write-Output "Running terraform init, plan, and destroy"
        terraform -chdir="$DestinationPath" init
        terraform -chdir="$DestinationPath" plan -destroy -out="$DestinationPath\destroy-plan.out"
        terraform -chdir="$DestinationPath" apply "$DestinationPath\destroy-plan.out"
    
        # Clean up and delete the state directory
        Write-Output "Cleaning up state directory"
        Remove-Item -Path "$DestinationPath" -Force -Recurse -ErrorAction SilentlyContinue
    }
    catch {
        Write-Output "Error: $($_.Exception.Message)"
        exit 1
    }
}

