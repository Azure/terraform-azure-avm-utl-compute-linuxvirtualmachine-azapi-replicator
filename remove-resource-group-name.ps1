# Script to remove 'resource_group_name = azurerm_resource_group.test.name' line from all azapi.tf.bak files

$rootPath = "q:\project\terraform-azure-avm-utl-compute-linuxvirtualmachine-azapi-replicator\azurermacctest"
$lineToRemove = "  resource_group_name = azurerm_resource_group.test.name"

# Find all azapi.tf.bak files in subdirectories
$files = Get-ChildItem -Path $rootPath -Recurse -Filter "azapi.tf.bak" -File

Write-Host "Found $($files.Count) azapi.tf.bak files" -ForegroundColor Cyan

foreach ($file in $files) {
    Write-Host "`nProcessing: $($file.FullName)" -ForegroundColor Yellow
    
    # Read the file content
    $content = Get-Content -Path $file.FullName -Raw
    
    # Check if the line exists
    if ($content -match [regex]::Escape($lineToRemove)) {
        # Remove the line (including the newline)
        $newContent = $content -replace "(?m)^\s*resource_group_name\s*=\s*azurerm_resource_group\.test\.name\s*$\r?\n", ""
        
        # Write back to file
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        
        Write-Host "  ✓ Removed line from $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "  - Line not found in $($file.Name)" -ForegroundColor Gray
    }
}

Write-Host "`nDone!" -ForegroundColor Cyan
