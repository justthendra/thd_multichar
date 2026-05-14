# 👥 thd_multichar | Character Selection

A visually stunning and high-performance multi-character selection system for the QBCore framework. It provides a modern entry point for players, allowing them to manage their digital identities.

![Version](https://img.shields.io/badge/Version-1.0.0-green?style=for-the-badge)
![Framework](https://img.shields.io/badge/Framework-QBCore-emerald?style=for-the-badge)

---

## ✨ Features

- **Immersive UI**: Modern character selection screen with a clean, glassmorphic design.
- **Cinematic Camera**: Smooth camera transitions and angles when switching between characters.
- **Character Metadata**: Displays essential information (Name, Job, Cash, Bank) at a glance.
- **Slot Management**: Supports multiple character slots based on server configuration.
- **Safe Deletion**: Secure character deletion process with confirmation prompts.
- **Optimized Loading**: Fast character data retrieval using `oxmysql`.

---

## 🎨 Design Philosophy

`thd_multichar` is designed to be the "Front Door" of the server:
- **Dynamic Lighting**: Optimized for various character models and outfits.
- **Ease of Use**: Intuitive navigation for new and returning players.

---

## 🛠️ Requirements

- **QBCore Framework**
- **oxmysql**
- **thd_identity** (Recommended for character creation)

---

## 🚀 Installation

1. Drag the `thd_multichar` folder into your `resources/[thd]` directory.
2. Add the following to your `server.cfg`:
   ```cfg
   ensure thd_multichar
   ```
3. Disable any other multicharacter scripts (e.g., `qb-multicharacter`).

---

## ⚙️ Technical Details

- **Frontend**: Vanilla HTML/CSS/JS.
- **Data**: Fetches character information directly from the QBCore `players` table.
- **Ped Spawning**: Handles client-side ped creation and outfit application for character previews.

---
