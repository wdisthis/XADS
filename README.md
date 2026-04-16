# XAMPP DATABASE AUTO-RECOVERY SYSTEM (XADS)

An automated Batch script designed to recover corrupted XAMPP MySQL services. **XADS** specifically targets the "Unexpected Shutdown" error while ensuring your critical data remain intact.

## The Problem: Why MySQL Fails

As a Data Science student or developer, you may frequently encounter the MySQL Shutdown Unexpectedly error. This issue is common in XAMPP due to: - Improper Shutdowns: Turning off the PC without stopping XAMPP services. - Zombie Processes: Multiple instances of `mysqld.exe` hanging in the background. - Corrupted Logs: Errors in `ib_logfile` that prevent the database engine from initializing. - PID Locks: Leftover `.pid` files that prevent a fresh start.

## he Solution: XADS Automation

**XADS.bat** automates the surgical recovery process. Below is a comparison of the manual approach versus the automated solution provided by this system:

| Step | Manual Recovery (High Risk) | XADS.bat (Automated & Safe) |
|:-----------------------|:-----------------------|:-----------------------|
| **Process Termination** | Finding and killing PIDs manually | Automated `taskkill` for all XAMPP processes |
| **Data Backup** | Manual Rename (Prone to overwriting) | Automated backup with unique Timestamps |
| **System Restoration** | Manual copy-paste from `/backup` | Instant structural rebuild of the data directory |
| **Data Migration** | Moving folders one by one | Smart filtering: Migrates only user DBs & `ibdata1` |

## Getting Started

### Prerequisites

-   Windows OS
-   XAMPP Installed
-   **Administrator Privileges** (Required for process management and file system access)

### How to Use

1.  Download the **`XADS.bat`** file.
2.  **Right-click** the file and select **Run as Administrator**.
3.  Enter your XAMPP installation path (e.g., `D:\xampp`) or simply press **Enter** to use the default `C:\xampp`.
4.  Wait for the `[OK] PROCESS COMPLETED` notification.
5.  Restart your XAMPP Control Panel and click **Start** on MySQL.

## Technical Methodology

XADS follows a precise recovery sequence: 1. **Force Purge**: Clears all `httpd.exe`, `mysqld.exe`, and `xampp-control.exe` instances from memory. 2. **Isolation**: Renames the corrupted `data` folder to `data_rusak_[Timestamp]` to preserve all existing data. 3. **Registry Rebuild**: Generates a clean `data` directory using verified files from the XAMPP `/backup` folder. 4. **Data Transplant**: Automatically moves your database schemas and the essential `ibdata1` (System Tablespace) into the newly created clean environment.

## Project Structure

``` text
XADS.bat    # The main recovery automation script
README.md   # Documentation
```
