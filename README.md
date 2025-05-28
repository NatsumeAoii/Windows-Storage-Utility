# 🧰 Windows Storage Utility (WSU)

**Windows Storage Utility** or **WSU** is a batch script for automating system repair tasks on Windows systems using built-in tools like **CHKDSK**, **SFC**, and **DISM**. It's designed to help diagnose and fix common file system and storage-related issues with a simple command-line interface.

> ⚠️ This script must be run as **Administrator**.

---

## 🔧 Features

- ✅ Check and repair disk using `CHKDSK /f /r /x`
- ✅ Verify and restore system file integrity using `SFC /scannow`
- ✅ Repair component store using `DISM /RestoreHealth`
- ✅ Automatically logs all outputs to system log folder
- ✅ Interactive and user-friendly text interface
- ✅ Useful for routine maintenance or troubleshooting

---

## 📂 Log Location

All log files are saved to:

```
C:\Windows\Logs\SystemRepair\
```

With filenames like:

* `COMPUTERNAME_CHKDSK_YYYY-MM-DD_HH-MM.log`
* `COMPUTERNAME_SFC_YYYY-MM-DD_HH-MM.log`
* `COMPUTERNAME_DISM_YYYY-MM-DD_HH-MM.log`

---

## 🚀 How to Use

1. **Right-click** the `Windows-Storage-Utility.bat` file
2. Choose **Run as administrator**
3. Follow the on-screen prompts

---

## ⚠️ Disclaimer

This tool is intended to **assist with minor storage-related issues**, such as:

* Soft bad sectors
* File system corruption
* System file integrity violations
* Component store corruption

It **does not** fix or diagnose hardware-level problems, such as:

* Failing or dead hard drives / SSDs
* Controller malfunctions
* Physical media damage
* Firmware-level corruption

> **Warning:**
> This script performs actions that may take a long time, such as disk scanning with `/f /r`, which checks for bad sectors. Please ensure that important data is backed up before running.
>
> This tool is provided **as-is** with no warranties. Use at your own risk.

---

## 💡 Notes

* CHKDSK on system drives (usually `C:`) will be scheduled on the next reboot.
* Make sure your `install.wim` or repair source is available at the configured path:
  `repairSource\install.wim`
  You may edit the script to match your own repair source location.

---

## 🛠️ System Requirements

* Windows 10 / 11
* Administrative privileges

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙌 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 📫 Contact

Have questions or suggestions? Reach out via Discord: `natsumeaoi`

---
