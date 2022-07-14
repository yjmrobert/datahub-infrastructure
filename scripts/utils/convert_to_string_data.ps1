# ==============================================================================
# Converts a hashtable to a string of key=value pairs.
# ==============================================================================
Function ConvertTo-StringData {
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