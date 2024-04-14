function ConvertTo-BrickStoreItem {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject[]]$WantedListItem
    )

    $ErrorActionPreference = 'Stop'

    foreach ($item in $WantedListItem) {
        $fields = @{
            ItemID     = $item.ITEMID
            ColorID    = $item.COLOR
            ItemTypeID = $item.ITEMTYPE
            Qty        = $item.MINQTY
        }
        if ($item.CONDITION -eq 'X') {
            $fields.Condition = 'U'
        } else {
            $fields.Condition = $item.CONDITION
        }
        [pscustomobject]$fields
    }
}