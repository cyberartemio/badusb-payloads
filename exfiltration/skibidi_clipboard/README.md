
<div align="center">
    <h1>🚽 Skibidi Clipboard 🚽</h1>
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
            <td><img src="https://img.shields.io/badge/-%F0%9F%98%88%20OMG-black?style=for-the-badge" alt="" /> <img src="https://img.shields.io/badge/-%F0%9F%90%AC%20Flipper-FF8200?style=for-the-badge&labelColor=FF8200" alt="" /></td>
            <td><img src="https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=apple&logoColor=white" alt="" /></td>
        </tr>
    </table>
</div>

This payload exfiltrates MacOS clipboard content periodically to a Discord channel. The payload is designed to be executed on MacOS and has been tested on MacOS 15.2. If you want to see it in action, check the [section below](#-showcase).

> [!IMPORTANT]
> In order to use this script, you need to host your version of the script on your remote server, **using a short URL** to speed up badUSB execution.

## ✨ Features
- Exfiltrates clipboard content periodically to Discord Server
- Easy to configure
  - Configure Discord webhook URL
  - Configure clipboard check period
- Exfiltrates only new clipboard content
- At startup send Discord message to notify target acquisition with some data about it
- Single execution command
- Clear shell history, removing all executed commands
- Only in memory, no file saved on the target
- Execute in the background
- Completely runs in less than 2 seconds

## 💰 Loot
- Clipboard content

## 💡 Usage
1. Create a new Discord webhook inside your Discord server
2. Download the payload locally on your pc:
   - For [OMG](https://raw.githubusercontent.com/cyberartemio/badusb-payloads/refs/heads/main/exfiltration/skibidi_clipboard/payload_for_omg.txt)
   - For [Flipper](https://raw.githubusercontent.com/cyberartemio/badusb-payloads/refs/heads/main/exfiltration/skibidi_clipboard/payload_for_flipper.txt)
3. Copy `skibidi_clipboard.sh` script on your HTTP server
4. Prepare your payload:
   - For **OMG**:
       1. on line 15, replace `<...>` with the URL of `skibidi_clipboard.sh` script hosted on your server
       2. On line 16, replace `<...>` with your freshly created webhook URL
       3. On line 17, replace `<...>` with the period (in seconds) for periodically checking the clipboard
   - For **Flipper**:
       1. on line 26, replace `<SCRIPT_SOURCE>` with the URL of `skibidi_clipboard.sh` script hosted on your server
       2. On line 26, replace `<DISCORD_WEBHOOK>` with your freshly created webhook URL
       3. On line 26, replace `<SLEEP_TIME>` with the period (in seconds) for periodically checking the clipboard

You now can execute the payload on the target machine.

## 🔥 Showcase
Take a look at the payload in action. In this GIF the payload is running on two different machines:

<div align="center">
    <img src="../../.github/assets/showcases/skibidi_clipboard.gif" alt="showcase" />
</div>