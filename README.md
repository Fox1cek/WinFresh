# WinFresh 🚀

One-click Windows setup script for fresh installs. Installs essential apps, removes bloatware, and applies privacy tweaks.

## ⚡ Quick Start

### Method 1: Download & Run (Recommended)
```powershell
# Download and run directly
irm https://raw.githubusercontent.com/Fox1cek/WinFresh/main/setup.ps1 | iex
```

### Method 2: Manual Download
1. Download `setup.ps1`
2. Right-click → "Run with PowerShell" (as Administrator)
3. Or run: `powershell -ExecutionPolicy Bypass -File setup.ps1`

## 📦 What's Installed

| Category | Apps |
|----------|------|
| **Browser** | Google Chrome |
| **Dev Tools** | VS Code, Git, Node.js |
| **Utilities** | 7-Zip, PowerToys, Notepad++, ShareX |
| **Media** | VLC, Spotify |
| **Gaming** | Steam, Discord |

## 🧹 What's Removed

- Xbox apps, Solitaire, Pinball
- Feedback Hub, Mixed Reality Portal
- Get Started, Office Hub, OneNote
- Various other Windows bloatware

## 🔒 Privacy Tweaks

- ✅ Disables telemetry
- ✅ Disables Cortana
- ✅ Removes Start menu ads
- ✅ Enables dark mode
- ✅ Shows file extensions

## ⚙️ Requirements

- Windows 10 (1809+) or Windows 11
- Administrator rights
- Internet connection

## 📝 Customization

Edit `setup.ps1` and modify the `$apps` array:

```powershell
$apps = @(
    @{ Name = "Your App"; Id = "Publisher.AppName" },
    # ... add more
)
```

Find app IDs with: `winget search "appname"`

## 🤝 Contributing

Pull requests welcome! Add more apps or improve the script.

## 📄 License

MIT - Use freely, modify as needed.
