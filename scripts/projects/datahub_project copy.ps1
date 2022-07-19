param(
    [Parameter(Mandatory)]
    $Environment,
    [Parameter(Mandatory)]
    $ProjectAcronym,
    $Location = "Canada Central"
)
    
$TemplateName = "project"
$ProjectRoot = "$PSScriptRoot\..\..";
$TemplatePath = "$ProjectRoot\templates\$TemplateName";
$DestinationPath = "$ProjectRoot\terraform\$Environment\projects\$ProjectAcronym";


. $ProjectRoot\scripts\utils\convert_to_string_data.ps1
. $ProjectRoot\scripts\utils\copy_tf_template.ps1
        

# ==============================================================================
# Copy the template to the destination path
# ==============================================================================

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

}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
