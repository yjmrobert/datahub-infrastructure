param(
    [Parameter(Mandatory)]
    $BackendConfig,
    [Parameter(Mandatory)]
    $DestinationPath,
    [Parameter(Mandatory)]
    $PathToStateStorageValues,
    [switch] $Destroy = $false
)
# $PathToStateStorageValues = "$DestinationPath\..\..\state\storage_account.values"

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
    try {

        # Run the terraform plan and apply scripts
        Write-Output "Running terraform init, plan, and apply with backend config at $BackendConfig";
        terraform -chdir="$DestinationPath" init -backend-config="$BackendConfig"
        terraform -chdir="$DestinationPath" plan -out="$DestinationPath\apply-plan.out"
        terraform -chdir="$DestinationPath" apply "$DestinationPath\apply-plan.out"
    }
    catch {
        Write-Output "Error applying terraform plan and apply scripts";
        Write-Output $_.Exception.Message;
        exit 1;
    }
}
# ==============================================================================
# Destroy
# ==============================================================================
else {
    try {
        # Run the terraform plan and apply (destroy) scripts
        Write-Output "Running terraform init, plan, and destroy wit backend config at $BackendConfig";
        terraform -chdir="$DestinationPath" init -backend-config="$BackendConfig"
        terraform -chdir="$DestinationPath" plan -destroy -out="$DestinationPath\destroy-plan.out"
        terraform -chdir="$DestinationPath" apply "$DestinationPath\destroy-plan.out"
        
        # Clean up and delete the directory
        Write-Output "Cleaning up directory at $DestinationPath";
        Remove-Item -Path "$DestinationPath" -Force -Recurse -ErrorAction SilentlyContinue
    }
    catch {
        Write-Output "Error applying terraform plan and destroy scripts";
        Write-Output $_.Exception.Message;
        exit 1;
    }
}

