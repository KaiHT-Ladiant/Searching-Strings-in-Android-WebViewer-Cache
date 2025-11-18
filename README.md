# Searching Strings in Android WebView Cache

A Windows batch script tool for security testing that searches for sensitive strings in Android WebView cache files on rooted devices.

## Purpose

This tool is designed for **penetration testers** and **security researchers** to identify sensitive information (such as login credentials, session tokens, personal data) stored in Android WebView cache files during security assessments.

## Features

- **Multiple Cache Path Options**
  - Automatic path detection via Objection integration
  - Manual path input
  - Default path scanning (`/data/data`, `/data/user/0`)

- **Flexible Device Support**
  - Rooted devices (using `su`)
  - Debuggable apps on non-rooted devices (using `run-as`)

- **Binary File Search**
  - Searches both text and binary cache files using `grep -a`
  - Handles WebView HTTP Cache (Cache_Data files)

- **Result Management**
  - Real-time search progress display
  - Save results to timestamped text files
  - Direct file opening with Notepad

## Prerequisites

### Required Tools
- **ADB (Android Debug Bridge)** - Must be in system PATH
- **Rooted Android Device** or debuggable app
- **Windows OS** - Tested on Windows 10/11
- **Frida Server** (running on device, if using Objection)

### Optional Tools
- **Objection** - For automatic cache path detection
```bat
pip3 install -U objection
```
## Installation
1. Clone this repository:
```bat
git clone https://github.com/KaiHT-Ladiant/Searching-Strings-in-Android-WebView-Cache.git
cd Searching-Strings-in-Android-WebView-Cache
```
2. Ensure ADB is installed and accessible:
```bat
adb version
```
3. Connect your rooted Android device via USB and enable USB debugging
4. (Optional) Install Objection for enhanced functionality:
```bat
pip3 install -U objection
```
## Usage
### Basic Usage
1. Run the batch script:
```bat
cache_search.bat
```
2. Enter the target application package name:
```bat
Input Application Package Name: com.example.app
```
3. Select cache path detection method:
```bat
Value in Objection env (Recommended - requires app running)[10]
User's Input Value (Manual path entry)[11]
Use Default Path (/data/data, /data/user/0)[12]
```
4. Enter the search string:
```bat
String Value: password
```
### Example Scenarios
#### Scenario 1: Finding User Credentials
```bat
Package Name: com.example.banking
Search String: userID
Result: Found in 2 files
```
#### Scenario 2: Session Token Discovery
```bat
Package Name: com.social.app
Search String: sessionToken
Result: Found in 5 cache files
```
#### Scenario 3: Using Objection Integration
```
Select (1/2/3): 1
[INFO] Bring Cache Path by Objection.
[OK] Cache Path Found: /data/user/0/com.example.app/cache
```
## How It Works

1. **Device Connection Check** - Verifies ADB device connectivity
2. **Root Permission Verification** - Checks for root access
3. **Cache Path Discovery** - Locates WebView cache directories
4. **File Enumeration** - Lists all cache files recursively
5. **String Search** - Uses `grep -a -i` for case-insensitive binary search
6. **Result Compilation** - Aggregates findings with file paths and line numbers

## Output Format

Search results are saved in the following format:
```
=========================================
FILE: /data/user/0/com.example.app/cache/WebView/Default/HTTP Cache/Cache_Data/f_00001a
23:username=admin
45:password=secretpass
67:sessionToken=abc123xyz
```

Output filename: `cache_search_[PACKAGE]_YYYYMMDD_HHMMSS.txt`

## Security Considerations

### Legal and Ethical Use
- **Only use on applications you have permission to test**
- Follow responsible disclosure practices
- Comply with local laws and regulations regarding security testing

### Common Findings
This tool may help identify the following security issues:
- **CWE-312**: Cleartext Storage of Sensitive Information
- **CWE-359**: Exposure of Private Personal Information
- **OWASP MASVS-STORAGE-2**: Sensitive Data in Application Logs

### Remediation Recommendations
If sensitive data is found in WebView cache:
- Implement proper cache control headers (`Cache-Control: no-store, no-cache`)
- Use `clearCache(true)` after handling sensitive data
- Avoid caching pages containing authentication credentials
- Consider using WebView's `setAppCacheEnabled(false)`

## Troubleshooting

### "Not Connected ADB Device"
- Check USB debugging is enabled
- Run `adb devices` to verify connection
- Try `adb kill-server` then `adb start-server`

### "You haven't Root permission"
- Ensure device is properly rooted
- Verify SuperSU/Magisk is granting shell access
- For debuggable apps, script will fallback to `run-as` method

### "Objection Detected Failed"
- Ensure target app is running on device
- Verify Frida server is active: `adb shell "ps | grep frida"`
- Check Objection installation: `objection version`
- Script will fallback to default paths automatically

### "Can't Find Cache File"
- Run the target app to generate WebView cache
- Verify package name is correct
- Try using Objection (Option 1) for accurate path detection

## Contributing
Contributions are welcome! Please feel free to submit issues or pull requests.
### Areas for Improvement
- Linux/macOS support
- Multi-device support
- Export results to CSV/JSON format
- GUI version
- Pattern-based search (regex support)
## Version History
- **v1.0** (2025-11-18)
  - Initial release
  - Basic string search functionality
  - Objection integration
  - Root and non-root support
## Author
**Kai_HT**
- Role: Penetration Testing Consultant
- GitHub: [[Kai_HT]](https://github.com/KaiHT-Ladiant/)
## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/KaiHT-Ladiant/Searching-Strings-in-Android-WebViewer-Cache/blob/main/LICENSE) file for details.
## Disclaimer
This tool is provided for educational and authorized security testing purposes only. The author is not responsible for any misuse or damage caused by this tool. Always obtain proper authorization before testing any application or system.
---
**Note**: This tool is designed for security professionals conducting authorized penetration tests. Unauthorized access to application data may violate laws in your jurisdiction.
