function New-BrickStoreFile {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [pscustomobject[]]$Item,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFilePath
    )

    $ErrorActionPreference = 'Stop'

    $allowedProperties = @(
        'ItemID'
        'ItemTypeID'
        'ColorID'
        'ItemName'
        'ItemTypeName'
        'ColorName'
        'CategoryID'
        'CategoryName'
        'Status'
        'Qty'
        'Price'
        'Condition'
        'Cost'
        'Remarks'
        'DateAdded'
        'DateLastSold'
        'Comments'
    )

    $requiredProperties = @(
        'ItemID'
        'ColorID'
        'ItemTypeID'
    )


    # Creating a new XML document for the output
    $xml = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("BrickStoreXML")
    $null = $xml.AppendChild($root)
    $inventory = $xml.CreateElement("Inventory")
    $null = $root.AppendChild($inventory)

    if ($PSBoundParameters.ContainsKey('Item')) {
        
        foreach ($i in $Item) {
            $itemNode = $xml.CreateElement("Item")
            foreach ($property in $i.PSObject.Properties) {
                if ($property.Name -notin $allowedProperties) {
                    throw "Property $($property.Name) is not allowed in a BrickStore file."
                }
                $element = $xml.CreateElement($property.Name)
                $null = $element.InnerText = $property.Value
                $null = $itemNode.AppendChild($element)
            }
            $null = $inventory.AppendChild($itemNode)
        }
    }

    $null = $xml.Save($OutputFilePath)
}