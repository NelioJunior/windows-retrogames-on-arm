# 🎮 Windows Retro Games on ARM

Run Windows 32-bit retro games on ARM64 single-board computers using Docker, Box86, and Wine — without modifying your host system.

> Tested on Raspberry Pi 4 (4GB RAM) running Debian 12 Bookworm (64-bit).

---

## 📋 Requirements

| Component | Minimum |
|-----------|---------|
| Hardware | Raspberry Pi 4/5, Radxa, Orange Pi, or any ARM64 SBC |
| RAM | 2GB or more |
| OS | Debian or Ubuntu based Linux (64-bit) |
| Software | Docker installed |
| Display | X11 session (not Wayland) |

---

## 🐳 Docker Hub

The pre-built image is available on Docker Hub:

```bash
docker pull nelljunior/retro-box86-wine-img
```

🔗 https://hub.docker.com/r/nelljunior/retro-box86-wine-img

---

## 📦 What's Inside the Image

| Component | Version |
|-----------|---------|
| Base OS | Debian 12 Bookworm (armhf 32-bit) |
| Box86 | v0.3.9 (with Dynarec) |
| Wine | 7.0 (i386) |
| OpenGL | Mesa (vc4 driver) |
| Audio | ALSA + PulseAudio support |

---

## 🎯 Compatible Games

Any Windows 32-bit game from the 90s/2000s era should work, including titles like:

- American McGee's Alice (2000/2011)
- Diablo II
- Baldur's Gate I & II
- Planescape: Torment
- Age of Empires II
- StarCraft
- Quake III Arena
- Half-Life
- Sid Meier's Civilization III

> ⚠️ 64-bit games are **not supported**. Games requiring DirectX 10/11/12 or modern DRM (Steam, Epic) may not work correctly.

---

## 🚀 Quick Start

### 1. Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Pull the image

```bash
docker pull nelljunior/retro-box86-wine-img
```

### 3. Download the launcher script

```bash
wget https://raw.githubusercontent.com/nelljunior/windows-retrogames-on-arm/main/game-launcher.sh
chmod +x game-launcher.sh
```

### 4. Allow X11 connections

```bash
xhost +local:
```

### 5. Run your game

```bash
./game-launcher.sh /path/to/your/game YourGame.exe
```

**Example with American McGee's Alice:**

```bash
./game-launcher.sh /media/user/USB/Alice1/bin alice.exe -RunningFromAlice2
```

---

## 🔧 How the Launcher Works

The `game-launcher.sh` script handles all the complexity automatically:

```bash
#!/bin/bash
# Usage: ./game-launcher.sh /path/to/game GameExecutable.exe [extra args]
GAME_PATH=$1
GAME_EXE=$2

xhost +local:
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null

docker run --rm \
  -e DISPLAY=:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v /run/user/1000/pulse/native:/run/user/1000/pulse/native \
  --device /dev/snd \
  --group-add audio \
  --privileged \
  --net=host \
  --device /dev/dri:/dev/dri \
  -v "$GAME_PATH":/game \
  nelljunior/retro-box86-wine-img \
  /bin/bash -c "cd /game && box86 wine $GAME_EXE"

xhost -local:
```

---

## 🏗️ Build from Source

If you prefer to build the image yourself:

```bash
git clone https://github.com/nelljunior/windows-retrogames-on-arm.git
cd windows-retrogames-on-arm
docker build --platform linux/arm/v7 -t retro-box86-wine .
```

> ⚠️ Build takes approximately 15-20 minutes on Raspberry Pi 4.

---

## ⚙️ Persisting Game Settings and Save Files

To keep your game configurations and save files between sessions, mount a local folder:

```bash
mkdir -p ~/game-saves
docker run --rm \
  ... \
  -v ~/game-saves:/root/saves \
  nelljunior/retro-box86-wine-img \
  /bin/bash -c "cd /game && box86 wine YourGame.exe"
```

---

## 🔊 Audio Troubleshooting

If you have no sound, run this command before launching the game:

```bash
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
```

---

## ❓ Known Limitations

- Only **32-bit Windows games** are supported
- **64-bit games** require a different setup (Box64 + Wine64)
- Games with modern DRM (Steam, Epic, SafeDisc) may not work
- Performance depends heavily on your hardware — Raspberry Pi 4 with 4GB+ RAM recommended
- Audio configuration may vary depending on your Linux distribution

---

## 🤝 Contributing

Found a game that works? Open an issue or pull request sharing your experience!

---

## 👤 Author

**Cornélio Domingues Júnior (Nell)**
- 🐳 Docker Hub: [nelljunior](https://hub.docker.com/u/nelljunior)
- 💼 LinkedIn: [corneliojunior-python](https://www.linkedin.com/in/corneliojunior-python)
- 🐙 GitHub: [nelljr](https://github.com/Nellltek)

---

## 📄 License

MIT License — feel free to use, modify and share!
