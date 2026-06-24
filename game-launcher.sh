#!/bin/bash
# Uso: ./game-launcher.sh /caminho/do/jogo NomeDoExecutavel.exe
GAME_PATH=$1
GAME_EXE=$2

xhost +local:
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null

docker run --rm \
  -e DISPLAY=:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v /run/user/1000/pulse/native:/run/user/1000/pulse/native \
  -e PULSE_SINK=alsa_output.platform-fe00b840.mailbox.stereo-fallback \
  --device /dev/snd \
  --group-add audio \
  --privileged \
  --net=host \
  --device /dev/dri:/dev/dri \
  -v "$GAME_PATH":/game \
  nelljunior/retro-box86-wine-img \
  /bin/bash -c "cd /game && box86 wine $GAME_EXE"

xhost -local: