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
        $FilesOnly = $false,
        [hashtable]$TerraformVars
    )

    . $PSScriptRoot\convert_to_string_data.ps1
    . $PSScriptRoot\merge_hashtables.ps1


    # If it's just the files in the template to copy
    if ($FilesOnly) {

        # Make sure the folder is there
        if (Test-Path -Path $DestinationPath) {
            # Copy the files from the template
            Write-Output "Copying $TemplateName files into $DestinationPath"
            Copy-Item -Path "$TemplatePath\*" -Destination $DestinationPath -Recurse -Force
        }
    }
    else {
        # Check if the folder is already there
        if (Test-Path -Path $DestinationPath) {
            Write-Output "Terraform folder for [$TemplateName] template already exist in [$Environment] environment"
            # Exit the script
            Exit 0
        }
        else {
            Write-Output "Copying terraform files into [$Environment/$TemplateName] environment"
            Copy-Item -Path $TemplatePath -Destination $DestinationPath -Recurse -Force
        }
    }

    # Create or update the terraform.tfvars file
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

    $TerraformVarsFile = "$DestinationPath\terraform.tfvars"

    if (Test-Path -Path $TerraformVarsFile) {
        Write-Output "Terraform variables file already exist in $DestinationPath, merging with new values"
        # Read in the existing terraform.tfvars file string data
        $ExistingTerraformVars = Get-Content $TerraformVarsFile | ForEach-Object { $_ -replace '"', '' } | Out-String | ConvertFrom-StringData
        $TerraformVars = Merge-Hashtables -Default $ExistingTerraformVars -Uppend $TerraformVars
    }
    ($TerraformVars | ConvertTo-StringData) | Out-File "$TerraformVarsFile" -Force -Encoding utf8
}

