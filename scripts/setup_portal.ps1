param(
    # [Parameter(Mandatory=$true)]
    $Environment       = "stg",
    # [Parameter(Mandatory=$true)]
    $Location          = "Canada Central", 
    # [Parameter(Mandatory=$true)]
    $TemplateName      = "portal",
    # [Parameter(Mandatory=$true)]
    $TemplatePath      = "$PSScriptRoot\..\terraform\templates\$TemplateName",
    # [Parameter(Mandatory=$true)]
    $DestinationPath   = "$PSScriptRoot\..\terraform\$Environment\$TemplateName",

    $PathToStorageValues = "$PSScriptRoot\..\terraform\$Environment\state\storage_account.values"
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
# Run the copy_tf_template script and copy the portal into the environment
# ==============================================================================
& $PSScriptRoot\copy_tf_template.ps1 `
    -Environment $Environment `
    -Location $Location `
    -TemplateName $TemplateName `
    -TemplatePath $TemplatePath `
    -DestinationPath $DestinationPath

# ==============================================================================
# Setup the remote state backend
# ==============================================================================
Write-Output "Reading state storage account values from $PathToStorageValues";
$StateStorageValues = Get-Content -Raw $PathToStorageValues | ConvertFrom-StringData;

Write-Output "Mapping state storage account values to backend configuration";
$TerraformBackend = @{
    "resource_group_name" = $StateStorageValues.resource_group_name;
    "storage_account_name" = $StateStorageValues.storage_account_name;
    "container_name" = $StateStorageValues.container_name;
    "key" = "$Environment.$TemplateName.tfstate";
}

Write-Output "Creating terraform backend configuration file";
($TerraformBackend | ConvertTo-StringData) | Out-File "$DestinationPath\$TemplateName.backend" -Force -Encoding utf8;

# ==============================================================================
# Run the terraform plan and apply scripts
# ==============================================================================
Write-Output "Running terraform init, plan, and apply"
$Env:TF_IN_AUTOMATION = "true";
$ACCOUNT_KEY=$(az storage account keys list --resource-group $StateStorageValues.resource_group_name --account-name $StateStorageValues.storage_account_name --query '[0].value' -o tsv)
$Env:ARM_ACCESS_KEY=$ACCOUNT_KEY

terraform -chdir="$DestinationPath" init -backend-config="$DestinationPath\$TemplateName.backend"
terraform -chdir="$DestinationPath" plan -out="$DestinationPath\plan.out"
terraform -chdir="$DestinationPath" apply "$DestinationPath\plan.out"