# 🧰 Windows Storage Utility (WSU) v1.0

**Windows Storage Utility** or **WSU** is an enhanced batch script for automating comprehensive system maintenance and repair tasks on Windows systems using built-in tools like **CHKDSK**, **SFC**, and **DISM**. It features an intuitive interface with real-time progress tracking and detailed logging capabilities.

> ⚠️ This script must be run as **Administrator**.

---

## 🔧 Features

<details>
<summary><strong>Click to expand full feature list</strong></summary>

- ✅ **Interactive Drive Selection** - Choose specific drives for CHKDSK analysis
- ✅ **Dynamic Volume Detection** - Automatically detects available system volumes
- ✅ **Comprehensive Disk Check** - Uses `CHKDSK /f /r` for thorough disk analysis and repair
- ✅ **System File Verification** - Runs `SFC /scannow` to verify and restore system file integrity
- ✅ **Component Store Repair** - Multi-stage DISM operations:
  - CheckHealth - Quick component store verification
  - ScanHealth - Detailed corruption scanning
  - RestoreHealth - Automatic repair of corrupted components
- ✅ **Real-time Progress Display** - Visual separators and progress indicators
- ✅ **Automatic Logging** - All operations logged with timestamps
- ✅ **Log Management** - Automatic cleanup of logs older than 30 days
- ✅ **Post-completion Options** - View logs, schedule restart, or exit
- ✅ **Enhanced User Experience** - Clear feedback and confirmation prompts

</details>

---

## 📂 Log Location

All log files are automatically saved to:

```
C:\Windows\Logs\StorageUtility\
```

<details>
<summary><strong>Log file naming convention</strong></summary>

With detailed filenames including:

* `COMPUTERNAME_CHKDSK_YYYY-MM-DD_HH-MM.log`
* `COMPUTERNAME_SFC_YYYY-MM-DD_HH-MM.log`
* `COMPUTERNAME_DISM_YYYY-MM-DD_HH-MM.log`

</details>

---

## 🚀 How to Use

1. **Right-click** the `WSU.bat` file
2. Choose **Run as administrator**
3. **Select target drive** from the detected volumes list
4. **Confirm your selection** when prompted
5. **Wait for completion** - The script will run all maintenance tasks automatically
6. **Choose post-completion action** - View logs, restart system, or exit

<details>
<summary><strong>Detailed Process Flow</strong></summary>

### 📋 Process Flow

```
[1/4] CHKDSK Analysis    → Disk integrity check and repair
[2/4] SFC Scan          → System file verification
[3/4] DISM CheckHealth  → Component store quick check
[4/4] DISM ScanHealth   → Detailed corruption scan
[5/4] DISM RestoreHealth → Automatic repair execution
```

### ⏱️ Expected Duration

- **CHKDSK**: 10-120 minutes (depending on drive size and condition)
- **SFC**: 5-15 minutes
- **DISM Operations**: 5-30 minutes total

> 💡 **Tip**: Larger drives and systems with more issues will take longer to process.

</details>

---

## ⚠️ Important Notes

### ✅ What This Tool Fixes:
* File system corruption and inconsistencies
* Soft bad sectors and logical errors
* System file integrity violations
* Windows component store corruption
* Registry inconsistencies related to system files

### ❌ What This Tool Cannot Fix:
* Physical hard drive failures
* Hardware controller malfunctions
* Severe physical media damage
* Firmware-level corruption
* Complete system crashes or boot failures

### 🔄 System Drive Behavior:
* CHKDSK on system drives (usually `C:`) may require a system restart
* Changes will be scheduled and applied during the next boot cycle
* Non-system drives can be repaired immediately

---

## 🛠️ System Requirements

<details>
<summary><strong>Click to view system requirements</strong></summary>

* **OS**: Windows 10 / 11 (Windows Server supported)
* **Privileges**: Administrator rights required
* **Disk Space**: Minimum 1GB free space for logging and temporary files
* **Memory**: 2GB RAM recommended for optimal performance

</details>

---

## 🔒 Safety & Backup

> **⚠️ Important Warning:**
> 
> While this utility uses Windows built-in tools and is generally safe, system maintenance operations can be intensive. Please ensure:
> 
> - Important data is backed up before running
> - System is connected to stable power source
> - No other disk-intensive operations are running
> - Sufficient time is available for completion

---

## 🆘 Troubleshooting

<details>
<summary><strong>Common issues and solutions</strong></summary>

**Script won't start:**
- Ensure you're running as Administrator
- Check if Windows Management Instrumentation service is running

**CHKDSK takes too long:**
- This is normal for large drives or drives with many issues
- Do not interrupt the process

**Logs not found:**
- Check if the log directory was created successfully
- Verify write permissions to `C:\Windows\Logs\`

</details>

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙌 Contributing

<details>
<summary><strong>Development Guidelines</strong></summary>

Pull requests and suggestions are welcome! For major changes, please open an issue first to discuss proposed modifications.

### Development Guidelines:
- Maintain backward compatibility
- Test on multiple Windows versions
- Follow existing code style and commenting
- Update documentation for new features

</details>

---

## 📫 Contact & Support

- **Discord**: `natsumeaoi`
- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: GitHub Discussions for general questions

---

## 🔄 Version History

<details>
<summary><strong>Version changelog</strong></summary>

**v1.0** - Enhanced Version
- Added interactive drive selection
- Implemented real-time progress tracking
- Enhanced logging with automatic cleanup
- Improved user interface with visual separators
- Added post-completion options menu

</details>

---
