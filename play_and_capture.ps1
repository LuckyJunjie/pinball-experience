# Play pinball and capture screenshot

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Start Godot with the project
$godotPath = "D:\game_development\godot\Godot_v4.5.1-stable_win64.exe"
$projectPath = "C:\Users\panju\.openclaw\workspace\pinball-experience"

$process = Start-Process -FilePath $godotPath -ArgumentList "--path",$projectPath -PassThru

# Wait for Godot to fully load
Start-Sleep -Seconds 6

# Switch to game scene (F5 to run)
[System.Windows.Forms.SendKeys]::SendWait("{F5}")
Start-Sleep -Seconds 4

# Wait for ball to launch
Start-Sleep -Seconds 4

# Simulate left flipper (left arrow)
[System.Windows.Forms.SendKeys]::SendWait("{LEFT}")
Start-Sleep -Milliseconds 300

# Simulate right flipper (right arrow)  
[System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
Start-Sleep -Milliseconds 300

# Wait for ball to move around
Start-Sleep -Seconds 2

# Take screenshot
$bitmap = New-Object System.Drawing.Bitmap(1920, 1080)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen(0, 0, 0, 0, [System.Drawing.Size]::new(1920, 1080))
$bitmap.Save("C:\Users\panju\.openclaw\workspace\pinball-experience\gameplay_action.png")
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Gameplay screenshot saved!"

# Close Godot
Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
