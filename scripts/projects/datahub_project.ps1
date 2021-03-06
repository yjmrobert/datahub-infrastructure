param(
    [Parameter(Mandatory)]
    $Environment,
    [Parameter(Mandatory)]
    $ProjectAcronym,
    $Location = "Canada Central",
    [switch] $Destroy = $false
)
    
$TemplateName = "project"
$ProjectRoot = "$PSScriptRoot\..\..";
$TemplatePath = "$ProjectRoot\templates\$TemplateName";
$DestinationPath = "$ProjectRoot\terraform\$Environment\projects\$ProjectAcronym";
$PathToStateStorageValues = "$DestinationPath\..\..\state\storage_account.values"


. $ProjectRoot\scripts\utils\convert_to_string_data.ps1
. $ProjectRoot\scripts\utils\copy_tf_template.ps1
        


# ==============================================================================
# Setup
# ==============================================================================

# Setup the remote state backend
Write-Output "Reading state storage account values from $PathToStateStorageValues";
$StateStorageValues = Get-Content -Raw $PathToStateStorageValues | ConvertFrom-StringData;

# Grab the storage account access keys from the state storage values
$Env:TF_IN_AUTOMATION = $true;
$ACCOUNT_KEY = $(az storage account keys list --resource-group $StateStorageValues.resource_group_name --account-name $StateStorageValues.storage_account_name --query '[0].value' -o tsv)
$Env:ARM_ACCESS_KEY = $ACCOUNT_KEY

# ==============================================================================
# Apply
# ==============================================================================
if (!$Destroy) {

    # Check if the project already exists
    if (Test-Path -Path $DestinationPath) {
        Write-Host "Datahub Project '$ProjectAcronym' already exists. Please destroy it before running this script or update the project manually."
        exit 1
    }

    try {

        # Run the copy tf template script and copy the project template into the environment
        $TerraformVars = @{
            "environment"     = $Environment;
            "location"        = $Location;
            "project-acronym" = $ProjectAcronym;
        }

        & Copy-Terraform-Template `
            -Environment $Environment `
            -Location $Location `
            -TemplateName $TemplateName `
            -TemplatePath $TemplatePath `
            -DestinationPath $DestinationPath `
            -TerraformVars $TerraformVars
        
        Write-Output "Mapping state storage account values to backend configuration";
        $TerraformBackend = @{
            "resource_group_name"  = $StateStorageValues.resource_group_name;
            "storage_account_name" = $StateStorageValues.storage_account_name;
            "container_name"       = $StateStorageValues.container_name;
            "key"                  = "$Environment.$TemplateName.$ProjectAcronym.tfstate";
        }
    
        Write-Output "Creating terraform backend configuration file at $DestinationPath\$TemplateName.backend";
        ($TerraformBackend | ConvertTo-StringData) | Out-File "$DestinationPath\$TemplateName.backend" -Force -Encoding utf8;
        
        # Run the terraform plan and apply scripts
        Write-Output "Running terraform init, plan, and apply with backend config at $DestinationPath\$TemplateName.backend";
        terraform -chdir="$DestinationPath" init -backend-config="$DestinationPath\$TemplateName.backend"
        terraform -chdir="$DestinationPath" plan -out="$DestinationPath\plan.out"
        terraform -chdir="$DestinationPath" apply "$DestinationPath\plan.out"
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
        exit 1
    }
}

# ==============================================================================
# Destroy
# ==============================================================================
else {
    
    # Check if the destination path already exists
    if (!(Test-Path -Path $DestinationPath)) {
        Write-Host "The project directory does not exist. Nothing to destroy."
        exit 0
    }

    try {
        # Run the terraform plan and apply (destroy) scripts
        Write-Output "Running terraform init, plan, and destroy wit backend config at $DestinationPath\project.backend";
        terraform -chdir="$DestinationPath" init -backend-config="$DestinationPath\project.backend"
        terraform -chdir="$DestinationPath" plan -destroy -out="$DestinationPath\destroy-plan.out"
        terraform -chdir="$DestinationPath" apply "$DestinationPath\destroy-plan.out"
    
        # Clean up and delete the directory
        Write-Output "Cleaning up directory at $DestinationPath";
        Remove-Item -Path "$DestinationPath" -Force -Recurse -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
        exit 1
    }
}