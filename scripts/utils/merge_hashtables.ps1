# ==============================================================================
# Upsert new values into a hashtable, taken from:
# https://stackoverflow.com/a/26409818
# ==============================================================================

Function Merge-HashTables {
    [CmdletBinding()]
    param(
        [hashtable] $Default, # Your original set
        [hashtable] $Uppend # The set you want to update/append to the original set
    )

    # Clone for idempotence
    $default1 = $default.Clone();

    # We need to remove any key-value pairs in $default1 that we will
    # be replacing with key-value pairs from $uppend
    foreach ($key in $uppend.Keys) {
        if ($default1.ContainsKey($key)) {
            $default1.Remove($key);
        }
    }

    # Union both sets
    return $default1 + $uppend;
}