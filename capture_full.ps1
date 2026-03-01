Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Wait for Godot to start
Start-Sleep -Seconds 3

# Get the screen
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

# Create bitmap
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Capture screen
$graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)

# Save
$bitmap.Save("C:\Users\panju\.openclaw\workspace\pinball-experience\screenshots\game_full.png")
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Screenshot saved to game_full.png"
