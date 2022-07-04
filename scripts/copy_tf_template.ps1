
param(
    $Environment       = "dev",
    $Location          = "Canada Central", 
    $TemplateName      = "state",
    $TemplatePath      = "$PSScriptRoot\..\terraform\templates\$TemplateName",
    $DestinationPath   = "$PSScriptRoot\..\terraform\$Environment\$TemplateName"
)
function ConvertTo-StringData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [HashTable[]]$HashTable
    )
    process {
        foreach ($item in $HashTable) {
            foreach ($entry in $item.GetEnumerator()) {
                "{0}={1}" -f $entry.Key, '"' + $entry.Value + '"'
            }
        }
    }
}

# ==============================================================================
# Copy the Terraform files to the state location
# ==============================================================================

# Check if the files are already there
if (Test-Path -Path $DestinationPath) {
    Write-Output "Terraform folder for [$TemplateName] template already exist in [$Environment] environment"
    # Exit the script
    Exit 0
} else {
    Write-Output "Copying terraform files into [$Environment/$TemplateName] environment"
    Copy-Item -Path $TemplatePath -Destination $DestinationPath -Recurse -Force
}

# Create the terraform.tfvars file with the following format
Write-Output "Creating terraform.tfvars file from mapped values"
$TerraformVars = @{
    "environment" = $Environment;
    "location" = $Location;
}

($TerraformVars | ConvertTo-StringData) | Out-File "$DestinationPath\terraform.tfvars" -Force




