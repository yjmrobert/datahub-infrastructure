param(
    [Parameter(Mandatory)]
    $DestinationPath,
    $BackendConfig,
    $PathToStateStorageValues,
    [switch] $Destroy = $false
)
# $PathToStateStorageValues = "$DestinationPath\..\..\state\storage_account.values"

# ==============================================================================
# Setup
# ==============================================================================

# If the path to state storage values is not specified, use the default path.
if ($null -ne $PathToStateStorageValues) {
    # Setup the remote state backend
    Write-Information "Reading state storage account values from $PathToStateStorageValues";
    $StateStorageValues = Get-Content -Raw $PathToStateStorageValues | ConvertFrom-StringData;
    
    # Grab the storage account access keys from the state storage values
    $Env:TF_IN_AUTOMATION = $true;
    $ACCOUNT_KEY = $(az storage account keys list --resource-group $StateStorageValues.resource_group_name --account-name $StateStorageValues.storage_account_name --query '[0].value' -o tsv)
    $Env:ARM_ACCESS_KEY = $ACCOUNT_KEY
}
else {
    Write-Information "Using local state storage";
}

# ==============================================================================
# Apply
# ==============================================================================
if (!$Destroy) {
    try {
        # Run the terraform plan and apply scripts
        if ($null -ne $BackendConfig) {
            Write-Information "Running terraform init, plan, and apply with backend config at $BackendConfig";
            terraform -chdir="$DestinationPath" init -backend-config="$BackendConfig" | Write-Information
        }
        else {
            Write-Information "Running terraform init";
            terraform -chdir="$DestinationPath" init | Write-Information
        }
        Write-Information "Running terraform plan";
        terraform -chdir="$DestinationPath" plan -out="apply.tfplan" | Write-Information
        
        Write-Information "Running terraform apply";
        terraform -chdir="$DestinationPath" apply "apply.tfplan" | Write-Information
        
        Write-Information "Successfully applied terraform configuration";
    }
    catch {
        Write-Information "Error applying terraform plan and apply scripts";
        Write-Information $_.Exception.Message;
        exit 1;
    }
}
# ==============================================================================
# Destroy
# ==============================================================================
else {
    try {
        # Run the terraform plan and apply (destroy) scripts
        if ($null -ne $BackendConfig) {
            Write-Information "Running terraform init, plan, and apply (destroy) with backend config at $BackendConfig";
            terraform -chdir="$DestinationPath" init -backend-config="$BackendConfig" | Write-Information
        }
        else {
            Write-Information "Running terraform init";
            terraform -chdir="$DestinationPath" init | Write-Information
        }
        
        Write-Information "Running terraform plan";
        terraform -chdir="$DestinationPath" plan -destroy -out="destroy-plan.tfplan"
        
        Write-Information "Running terraform apply (destroy)";
        terraform -chdir="$DestinationPath" apply "destroy-plan.tfplan"
        
        # Clean up and delete the directory
        Write-Information "Cleaning up directory at $DestinationPath";
        Remove-Item -Path "$DestinationPath" -Force -Recurse -ErrorAction SilentlyContinue
    }
    catch {
        Write-Information "Error applying terraform plan and destroy scripts";
        Write-Information $_.Exception.Message;
        exit 1;
    }
}

