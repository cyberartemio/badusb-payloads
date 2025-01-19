# 😈 BadUSB Payloads
[![Discord server](https://img.shields.io/badge/Discord%20server-7289da?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/5vrJbbW3ve)

## ℹ️ Introduction
In this repository you can find some BadUSB payloads that I wrote. The payloads are mainly designed to be executed on OMG devices or on Flipper Zero, but with some changes they should work also on Rubber Ducky.

### Structure of the repo
In the root directory there are various folders representing the categories of the payloads. *The logic is the same that is followed by Hak5 payloads repos.*

Inside each category's directory, you'll find a folder for each payload with its name..

Finally, inside the directory of the payload, you'll find the actual BadUSB payload (generally 2 versions, one for OMG and one for Flipper), optionally resources supporting it, and a `README.md` file with a detailed description of what it does and how to use it.

## Available payloads
| For | Type | Category | Target | Name | PnP | Description |
| --- | --- | --- | --- | --- | --- | --- |
| ![](https://img.shields.io/badge/%F0%9F%90%AC-Flipper-FF8200?style=flat-square&labelColor=FF8200) | ![](https://img.shields.io/badge/%E2%9A%92%EF%B8%8F-Benign-green?style=flat-square&labelColor=green) | ![](https://img.shields.io/badge/%F0%9F%A4%96-Execution-blue?style=flat-square&labelColor=blue) | ![](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black) | [Bro, can you send me the FAP?](./execution/bro_can_you_send_me_the_fap/README.md) | 🟡 | This scripts automates FAP build for people who don't know how to do it. |