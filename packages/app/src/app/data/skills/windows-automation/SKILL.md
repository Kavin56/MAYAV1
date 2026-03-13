# Windows Automation Skill

This skill provides Windows-specific automation capabilities for MAYA.

## Features

- Process management (start, stop, monitor)
- Application control
- System information gathering
- File operations
- Network diagnostics
- Window management
- Clipboard automation

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Administrator permissions for some operations (registry, services)

## Setup

No additional setup required - this skill works out of the box using PowerShell.

## Usage

Once this skill is loaded, you can:

1. **Launch applications**: "Open Chrome browser"
2. **Close applications**: "Close all Chrome windows"
3. **Check system info**: "Show me running processes"
4. **File automation**: "Create a new folder called Test"
5. **Network checks**: "Check if google.com is reachable"

## Commands Available

- `windows-list-processes` - List running processes
- `windows-launch-app` - Launch an application
- `windows-close-app` - Close an application
- `windows-system-info` - Get system information
- `windows-network-test` - Test network connectivity
- `windows-screenshot` - Take a screenshot
- `windows-clipboard-get` - Get clipboard content
- `windows-clipboard-set` - Set clipboard content

## Safety

All destructive operations require user confirmation before execution.
