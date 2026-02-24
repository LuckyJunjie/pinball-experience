Add-Type -AssemblyName System.Drawing

$bitmap = New-Object System.Drawing.Bitmap(1920, 1080)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen(0, 0, 0, 0, [System.Drawing.Size]::new(1920, 1080))
$bitmap.Save("C:\Users\panju\.openclaw\workspace\pinball-experience\desktop.png")
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Screenshot saved!"
