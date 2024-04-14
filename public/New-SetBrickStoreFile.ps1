function New-SetBrickStoreFile {
    <#
        .SYNOPSIS
            Creates a BSX file of parts from a set.
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SetNumber,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath
    )

    $ErrorActionPreference = 'Stop'

    try {
        $setItems = Get-SetPartList -SetNumber $SetNumber

        $bsItems = foreach ($setItem in $setItems) {
            if ($setItem.item.type -eq 'PART') {
                $bsItemTypeId = 'P'
            } else {
                Write-Error -Message "Unknown item type $($setItem.item.type)"
            }
            [pscustomobject]@{
                ItemID     = $setitem.item.no
                ItemTypeID = $bsItemTypeId
                Qty        = $setItem.quantity
                ColorID    = $setItem.color_id
                Comments   = "SET: $($SetNumber)"
            }
        }

        New-BrickStoreFile -Item $bsItems -OutputFilePath $FilePath
    } catch {
        Write-Error -Message  $_.Exception.Message
    }
}