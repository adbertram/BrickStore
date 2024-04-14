function New-WantedListBrickStoreFile {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath
    )

    $ErrorActionPreference = 'Stop'

    try {
        $wantedLists = Get-WantedList
        if (-not $wantedLists) {
            throw 'Did not find any wanted lists.'
        }
        Write-Information -Message "Found $($wantedLists.Count) total wanted lists."

        $bsItems = @()
        foreach ($wantedList in $wantedLists) {
            if (-not ($wlItems = Get-WantedListItem -WantedListId $wantedList.id)) {
                Write-Error -Message "No items found for wanted list ID $($wantedList.id)"
            } else {
                Write-Information -Message "Found $($wlItems.Count) total set wanted list items in wanted list $()"
                foreach ($wi in $wlItems) {
                    #region Consolidate lots that are wanted across mulitple sets
                    $foundExistingLot = $false
                    for ($i = 0; $i -lt $bsItems.Count; $i++) {
                        if ($bsItems[$i].ItemID -eq $wi.ITEMID -and $bsItems[$i].ColorID -eq $wi.COLOR) {
                            $bsItems[$i].Qty = [int]$bsItems[$i].Qty + [int]$wi.MINQTY
                            $bsItems[$i].Comments += ", $($wantedList.name)-$($wi.MINQTY)"
                            Write-Information -Message "Found existing lot for item ID $($bsItems[$i].ItemID)/Color ID $($bsItems[$i].ColorID). Merging..."
                            $foundExistingLot = $true
                            break
                        }
                    }
                    #endregion
                    if (-not $foundExistingLot) {
                        $bsItem = ConvertTo-BrickStoreItem -WantedListItem $wi
                        $bsItems += $bsItem | Add-Member -NotePropertyName 'Comments' -NotePropertyValue "$($wantedList.name)-$($bsItem.Qty)" -PassThru
                    }
                }
            }
        }

        New-BrickStoreFile -Item $bsItems -OutputFilePath $FilePath
    } catch {
        Write-Error -Message  $_.Exception.Message
    }
}