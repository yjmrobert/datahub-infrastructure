# ==============================================================================
# Copy the Terraform files to the destination
# ==============================================================================
function Copy-Terraform-Template {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Environment,
        [Parameter(Mandatory = $true)]
        $Location, 
        [Parameter(Mandatory = $true)]
        $TemplateName,
        [Parameter(Mandatory = $true)]
        $TemplatePath,
        [Parameter(Mandatory = $true)]
        $DestinationPath,
        [hashtable]$TerraformVars
    )

    . $PSScriptRoot\convert_to_string_data.ps1

    # Check if the files are already there
    if (Test-Path -Path $DestinationPath) {
        Write-Output "Terraform folder for [$TemplateName] template already exist in [$Environment] environment"
        # Exit the script
        Exit 0
    }
    else {
        Write-Output "Copying terraform files into [$Environment/$TemplateName] environment"
        Copy-Item -Path $TemplatePath -Destination $DestinationPath -Recurse -Force
    }

    # Create the terraform.tfvars file
    if ($TerraformVars) {
        Write-Output "Creating terraform.tfvars file from mapped values"
    }
    else {
        Write-Output "Creating terraform.tfvars file from default values"
        $TerraformVars = @{
            "environment" = $Environment;
            "location"    = $Location;
        }
    }
    ($TerraformVars | ConvertTo-StringData) | Out-File "$DestinationPath\terraform.tfvars" -Force -Encoding utf8
}