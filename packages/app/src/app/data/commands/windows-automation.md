---
name: windows-automation
description: Execute Windows automation tasks using PowerShell - control apps, manage processes, system operations
---

# Windows Automation Command

You have access to Windows automation capabilities via PowerShell. Use these commands to automate Windows tasks.

## Available Actions

### 1. Launch Applications
```powershell
Start-Process "notepad"
Start-Process "calc"
Start-Process "excel"
Start-Process "chrome"
Start-Process "C:\path\to\application.exe"
```

### 2. Close Applications
```powershell
Stop-Process -Name "notepad" -Force
Stop-Process -Name "chrome" -Force
Stop-Process -Id 1234
```

### 3. List Running Processes
```powershell
Get-Process
Get-Process | Where-Object {$_.CPU -gt 10}
Get-Process -Name "chrome","notepad"
```

### 4. System Information
```powershell
Get-ComputerInfo
Get-Process | Select-Object Name, CPU, WorkingSet
systeminfo
```

### 5. File Operations
```powershell
Get-ChildItem -Path "C:\Users" -Recurse
New-Item -Path "C:\test.txt" -ItemType File
Remove-Item -Path "C:\test.txt" -Force
```

### 6. Registry Operations (Read only for safety)
```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion"
```

### 7. Network Operations
```powershell
Get-NetIPAddress
Test-NetConnection -ComputerName "google.com"
netstat -ano
```

### 8. Service Management
```powershell
Get-Service
Start-Service -Name "Spooler"
Stop-Service -Name "Spooler"
```

### 9. Clipboard Operations
```powershell
Get-Clipboard
Set-Clipboard -Value "Hello World"
```

### 10. Window Management
```powershell
# Get all open windows
Get-Process | Where-Object {$_.MainWindowTitle -ne ""} | Select-Object MainWindowTitle, ProcessName

# Minimize all
(New-Object -ComObject Shell.Application).MinimizeAll()

# Restore all
(New-Object -ComObject Shell.Application).UndoMinimizeAll
```

## Usage Examples

When the user asks for Windows automation, follow these rules:

1. **Always confirm before executing destructive commands** (delete, kill process, registry writes)
2. **Use PowerShell syntax** - more powerful than CMD
3. **Wrap complex commands in script blocks** for better handling
4. **Check if process exists before trying to stop it**

## Example Workflows

### Open specific app and wait
1. `Start-Process "notepad" -Wait` - Opens notepad and waits for it to close

### Take screenshot
```powershell
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Screen]::PrimaryScreen.Bounds
```

### Monitor a process
```powershell
while (Get-Process -Name "notepad" -ErrorAction SilentlyContinue) { 
    Start-Sleep -Seconds 5 
}
Write-Host "Process ended"
```

## Safety Guidelines

- ❌ DO NOT: Delete system files
- ❌ DO NOT: Modify registry keys in HKLM:\ (requires admin)
- ❌ DO NOT: Force kill system processes
- ✅ DO: Work with user files and applications
- ✅ DO: Read system information
- ✅ DO: Manage user-space applications

When in doubt, ask the user for confirmation before executing potentially destructive commands.
