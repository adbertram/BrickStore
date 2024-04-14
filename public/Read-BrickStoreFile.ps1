function Read-BrickStoreFile {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath
    )

    $ErrorActionPreference = 'Stop'

    $xBsFile = [xml](Get-Content -Path $FilePath -Raw)

    $xbsfile.BrickStoreXML.Inventory.Item
}