---
name: file-automation
description: Automate file operations - create, read, write, organize files and folders
---

# File Automation Command

You can automate various file and folder operations on Windows.

## Available Actions

### 1. List Files and Folders
```powershell
# List current directory
Get-ChildItem

# List with details
Get-ChildItem | Format-Table Name, Length, LastWriteTime

# List specific type
Get-ChildItem -Filter "*.txt"
Get-ChildItem -Recurse -Include "*.pdf"

# Show folder structure
Get-ChildItem -Recurse | Select-Object FullName
```

### 2. Create Files/Folders
```powershell
# Create folder
New-Item -Path "C:\TestFolder" -ItemType Directory

# Create file with content
"Hello World" | Out-File -FilePath "C:\test.txt"

# Create file with multiple lines
@"
Line 1
Line 2
Line 3
"@ | Out-File -FilePath "C:\multiline.txt"
```

### 3. Read Files
```powershell
# Read entire file
Get-Content "C:\test.txt"

# Read first few lines
Get-Content "C:\test.txt" -TotalCount 10

# Read as lines
Get-Content "C:\test.txt" | Select-Object -First 20
```

### 4. Write/Edit Files
```powershell
# Overwrite file
"New content" | Out-File -FilePath "C:\test.txt"

# Append to file
"Another line" | Out-File -FilePath "C:\test.txt" -Append

# Copy file
Copy-Item "C:\source.txt" -Destination "C:\backup.txt"

# Move/Rename file
Move-Item "C:\old.txt" -Destination "C:\new.txt"
```

### 5. Delete Files/Folders
```powershell
# Delete file
Remove-Item "C:\test.txt"

# Delete folder (recursive)
Remove-Item -Path "C:\TestFolder" -Recurse -Force

# Delete files matching pattern
Remove-Item -Path "C:\*.tmp" -Force
```

### 6. Search Files
```powershell
# Find files by name
Get-ChildItem -Recurse -Filter "*.pdf"

# Find files containing text
Select-String -Path "C:\*.txt" -Pattern "search term"

# Find large files
Get-ChildItem -Recurse | Where-Object {$_.Length -gt 100MB}
```

### 7. File Properties
```powershell
# Get file info
Get-Item "C:\test.txt" | Select-Object Name, Length, CreationTime, LastWriteTime

# Set file timestamp
(Get-Item "C:\test.txt").LastWriteTime = Get-Date
```

### 8. Zip/Compress
```powershell
# Create zip
Compress-Archive -Path "C:\Folder" -DestinationPath "C:\archive.zip"

# Extract zip
Expand-Archive -Path "C:\archive.zip" -DestinationPath "C:\Extract"
```

## Safety Guidelines

- ❌ DO NOT: Delete system files
- ❌ DO NOT: Access files outside workspace without permission
- ✅ DO: Work in user-specified directories
- ✅ DO: Confirm before deleting files
- ✅ DO: Create backups before major operations

## Tips

1. Use tab completion for file paths
2. Always check file exists before operations
3. Use `-WhatIf` flag to preview operations (e.g., `Remove-Item -WhatIf`)
4. Use `-ErrorAction Stop` for critical operations
