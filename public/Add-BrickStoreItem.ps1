function Add-BrickStoreItem {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ColorId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$Quantity,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('N', 'U')]
        [string]$Condition = 'U',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Remarks,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [decimal]$Price,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$BulkQuantity
    )

    $ErrorActionPreference = 'Stop'

    $paramToXmlMap = @{
        ItemNumber   = 'ItemID'
        ColorId      = 'ColorID'
        Quantity     = 'Qty'
        Condition    = 'Condition'
        Remarks      = 'Remarks'
        Price        = 'Price'
        BulkQuantity = 'Bulk'
    }

    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        New-BrickStoreFile -OutputFilePath $FilePath
    }

    # Load the XML document
    [xml]$xmlDoc = Get-Content -Path $FilePath

    # Create a new element
    $itemNode = $xmlDoc.CreateElement("Item")

    $element = $xmlDoc.CreateElement('ItemID')
    $element.InnerText = $ItemNumber
    $null = $itemNode.AppendChild($element)

    $element = $xmlDoc.CreateElement('ItemTypeID')
    $element.InnerText = 'P' ## assuming this item is always going to be a part
    $null = $itemNode.AppendChild($element)

    ## This can't go in the bound parameters loop because there's a default value
    $element = $xmlDoc.CreateElement('Condition')
    $element.InnerText = $Condition
    $null = $itemNode.AppendChild($element)

    # Inventory element
    $parentElement = $xmlDoc.SelectSingleNode("//Inventory")

    foreach ($param in $PSBoundParameters.GetEnumerator().where({ $_.Key -notin @('ItemNumber', 'FilePath') })) {
        $element = $xmlDoc.CreateElement($paramToXmlMap[$param.Key])
        $element.InnerText = $param.Value
        $null = $itemNode.AppendChild($element)
    }

    # Append the new element to the parent element
    $null = $parentElement.AppendChild($itemNode)

    # Save the changes back to the XML file
    $xmlDoc.Save($FilePath)    
}