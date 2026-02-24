# Run Godot and capture screenshot

# Start Godot in background
Start-Process -FilePath 'D:\game_development\godot\Godot_v4.5.1-stable_win64.exe' -ArgumentList '--path','C:\Users\panju\.openclaw\workspace\pinball-experience','-s','screenshot_auto.gd' -WindowStyle Normal

# Wait for Godot to start and load
Start-Sleep -Seconds 8

# Take screenshot
Add-Type -AssemblyName System.Drawing
$bitmap = New-Object System.Drawing.Bitmap(1920, 1080)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen(0, 0, 0, 0, [System.Drawing.Size]::new(1920, 1080))
$bitmap.Save("C:\Users\panju\.openclaw\workspace\pinball-experience\godot_screenshot.png")
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Screenshot saved!"

# Close Godot
Get-Process -Name "Godot*" -ErrorAction SilentlyContinue | Stop-Process -Force
