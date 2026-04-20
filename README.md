# XAMPP DATABASE AUTO-RECOVERY SYSTEM (XADS)

An automated Batch script designed to recover corrupted XAMPP MySQL services. **XADS** specifically targets the "Unexpected Shutdown" error while ensuring your critical data remain intact.

## The Problem: Why MySQL Fails

As a Data Science student or developer, you may frequently encounter the MySQL Shutdown Unexpectedly error. This issue is common in XAMPP due to:
- **Improper Shutdowns**: Turning off the PC without stopping XAMPP services.
- **Zombie Processes**: Multiple instances of `mysqld.exe` hanging in the background.
- **Corrupted Logs**: Errors in `ib_logfile` that prevent the database engine from initializing.
- **PID Locks**: Leftover `.pid` files that prevent a fresh start.

## The Solution: XADS Automation

**XADS.bat** automates the surgical recovery process. Below is a comparison of the manual approach versus the automated solution:

| Step | Manual Recovery (High Risk) | XADS.bat (Automated & Safe) |
|:---|:---|:---|
| **Process Termination** | Finding and killing PIDs manually | Automated `taskkill` for all XAMPP processes |
| **Data Backup** | Manual Rename (Prone to overwriting) | Automated backup with unique Timestamps |
| **System Restoration** | Manual copy-paste from `/backup` | Instant structural rebuild of the data directory |
| **Data Migration** | Moving folders one by one | Smart filtering: Migrates only user DBs & `ibdata1` |

## ✨ New Features (v2.0)

- 🎨 **Visual Feedback**: Colorful terminal UI for better readability.
- 🔍 **Auto-Detection**: Automatically falls back to standard text if ANSI colors are not supported.
- 🛡️ **Confirmation Prompt**: Asks for your permission before performing any destructive actions.
- 📊 **Progress Tracking**: Shows real-time migration status for each database.
- 🚀 **Quick Restart**: Direct option to reopen XAMPP Control Panel once finished.

## Getting Started

### Prerequisites

- Windows OS (Windows 10 Version 1607+ for full color support)
- XAMPP Installed
- **Administrator Privileges** (Required for process management)

### How to Use

1. Download the **`XADS.bat`** file.
2. **Right-click** the file and select **Run as Administrator**.
3. Follow the interactive prompts:
    - Specify your XAMPP path (or hit Enter for default).
    - Confirm the recovery action.
4. Watch the progress bar as your databases are migrated.
5. Choose whether to reopen XAMPP Control Panel at the end.

## Technical Methodology

XADS follows a precise recovery sequence:
1. **Force Purge**: Clears all `httpd.exe`, `mysqld.exe`, and `xampp-control.exe` instances.
2. **Isolation**: Renames the corrupted `data` folder with a unique timestamp.
3. **Registry Rebuild**: Generates a clean `data` directory using verified backup files.
4. **Data Transplant**: Migrates database schemas and `ibdata1` into the clean environment.

## Project Structure

```text
XADS.bat    # The main recovery automation script
README.md   # Documentation
```

