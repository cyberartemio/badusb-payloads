<div align="center">
    <h1>💰 MacDoxx 💰</h1>
    <table>
        <tr align="center">
            <td><b>Category</b></td>
            <td><b>Type</b></td>
            <td><b>For</b></td>
            <td><b>Target</b></td>
        </tr>
        <tr align="center">
            <td><img src="https://img.shields.io/badge/-%F0%9F%92%B0%20Exfiltration-purple?style=for-the-badge" alt="" /></td>
            <td><img src="https://img.shields.io/badge/-%E2%9A%94%EF%B8%8F%20Malicious-EA2027?style=for-the-badge" alt="" /></td>
            <td><img src="https://img.shields.io/badge/-%F0%9F%98%88%20OMG-black?style=for-the-badge" alt="" /></td>
            <td><img src="https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=apple&logoColor=white" alt="" /></td>
        </tr>
    </table>
</div>

This payload exfiltrates a lot of information about the target where it has been executed. This includes but is not limited to installed applications list, clipboard content, browser history of the last 7 days, private and public SSH keys. Check the section [below](#-loot) to see everything that is collected. It is possible to exfiltrate the loot through Dropbox, Telegram or Discord.

> [!IMPORTANT]
> In order to use this script, you need to host your version of the script on your remote server, **using a short URL** to speed up badUSB execution.

## ✨ Features
- Collect loot about the target which can be analyzed to further identify vulnerabilities and attack vectors
- **Multiple exfiltration methods**: Dropbox, Telegram, Discord
- Easy to configure
  - Configure exfiltration token/key
- Loot exfiltrated as a txt file
- Single execution command
- Clear shell history, removing all executed commands
- Execute in the background
- Completely runs in less than 7 seconds

## 💰 Loot
- **User loot**
    - Username
    - User's fullname
    - Email address used with iCloud
    - Clipboard content
    - User default shell
    - Shell commands history
    - SSH config file
    - SSH private and public keys
- **System loot**
    - Hostname
    - System's uptime
    - MacOS version
    - Kernel version
    - Hardware model
- **Disks loot**
  - Disks list with available space and other information
- **Network loot**
  - Network interfaces with MAC address and IP address
  - Name of the WiFi's SSID on which the mac is currently connected
  - Public IP address
  - List of nearby WiFi's SSIDs
  - List of previously connected WiFi's SSIDs
- **Processes loot**
  - CPU and RAM usage
  - Currently logged in users
  - List of running processes
  - List of outgoing active connections
- **Applications loot**
  - Availability of Homebrew
  - Version of Homebrew
  - List of applications installed with Homebrew
  - Availability of XCode Tools
  - List of installed applications (includes system applications and App Store applications)
- **Browsers loot**
  - Default browser name
  - Safari history of last 7 days
  - Chrome history of last 7 days
  - Firefox history of last 7 days

## 💡 Usage
1. Prepare your exfiltration environment:
   - For **Telegram**:
     - Register a new bot with Botfather on Telegram
     - Take note of bot token and your chat id
   - For **Discord**:
     - Create a new Discord webhook inside your Discord server
   - For **Dropbox**:
     - Register a new OAuth application
     - Register a development token for your app
2. Download the payload locally on your pc from [here](https://raw.githubusercontent.com/cyberartemio/badusb-payloads/refs/heads/main/exfiltration/macdoxx/payload_for_omg.txt)
3. Copy `macdoxx.sh` script on your HTTP server
4. On line 14, replace `<...>` with the URL of `macdoxx.sh` script hosted on your server
6. On line 15, replace `<...>` with the exfiltration method. Use:
   - `tg` for **Telegram**
   - `ds` for **Discord**
   - `db` for **Dropbox**
7. On line 16, replace `<...>` with the exfiltration token string. Use the following econding format depending on the choosen exfil environment:
   - For **Telegram** add your bot token and chat id separated by a comma: `bot_token,chat_id`
   - For **Discord** add your webhook URL
   - For **Dropbox** add your OAuth API key

You now can execute the payload on the target machine. The script will run in background and you'll receive the loot as a txt file on the platform that you choose as the exfiltration method.