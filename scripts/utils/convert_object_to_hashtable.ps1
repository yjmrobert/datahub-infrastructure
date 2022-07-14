# ==============================================================================
# Converts an object's properties to a hashtable.
# ==============================================================================
Function Convert-ObjectToHashTable {
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [pscustomobject] $Object
    )
    $HashTable = @{}
    $ObjectMembers = Get-Member -InputObject $Object -MemberType *Property
    foreach ($Member in $ObjectMembers) {
        $HashTable.$($Member.Name) = $Object.$($Member.Name)
    }
    return $HashTable
}