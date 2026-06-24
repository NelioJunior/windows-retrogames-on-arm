FROM arm32v7/debian:bookworm

# Evitar prompts interativos durante instalacao
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias essenciais numa unica camada
# (tudo junto pra nao criar camadas intermediarias)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Ferramentas basicas
    wget \
    gnupg \
    ca-certificates \
    # Libs graficas X11
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxrandr2 \
    libxi6 \
    libxcursor1 \
    libxfixes3 \
    libxinerama1 \
    libxcomposite1 \
    libxxf86vm1 \
    libxshmfence1 \
    # Libs OpenGL/Mesa
    libgl1 \
    libgl1-mesa-dri \
    libglx-mesa0 \
    libglx0 \
    libglvnd0 \
    libdrm2 \
    # Libs de fonte
    libfreetype6 \
    fontconfig \
    fonts-dejavu-core \
    # Audio
    libasound2 \
    # Libs de sistema necessarias pro Wine
    libglib2.0-0 \
    libdbus-1-3 \
    libgnutls30 \
    libssl3 \
    libgcc-s1 \
    libstdc++6 \
    libc6 \
    # Instalar Box86 via repositorio oficial
    && wget https://ryanfortner.github.io/box86-debs/box86.list \
       -O /etc/apt/sources.list.d/box86.list \
    && wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg \
       | gpg --dearmor -o /usr/share/keyrings/box86-debs-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/box86-debs-archive-keyring.gpg] \
       https://ryanfortner.github.io/box86-debs/debian ./" \
       > /etc/apt/sources.list.d/box86.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends box86-rpi4arm64 \
    # Baixar, extrair e instalar Wine - tudo na mesma camada
    && mkdir -p /tmp/wine-install \
    && wget -q -P /tmp/wine-install \
       https://dl.winehq.org/wine-builds/debian/dists/bullseye/main/binary-i386/wine-stable-i386_7.0.0.0~bullseye-1_i386.deb \
    && wget -q -P /tmp/wine-install \
       https://dl.winehq.org/wine-builds/debian/dists/bullseye/main/binary-i386/wine-stable_7.0.0.0~bullseye-1_i386.deb \
    && dpkg-deb -x /tmp/wine-install/wine-stable-i386_7.0.0.0~bullseye-1_i386.deb /tmp/wine-install/extracted \
    && dpkg-deb -x /tmp/wine-install/wine-stable_7.0.0.0~bullseye-1_i386.deb /tmp/wine-install/extracted \
    && mv /tmp/wine-install/extracted/opt/wine-stable /opt/wine \
    # Criar links simbolicos do Wine
    && ln -sf /opt/wine/bin/wine /usr/local/bin/wine \
    && ln -sf /opt/wine/bin/winecfg /usr/local/bin/winecfg \
    && ln -sf /opt/wine/bin/wineserver /usr/local/bin/wineserver \
    && ln -sf /opt/wine/bin/wineboot /usr/local/bin/wineboot \
    # Desabilitar XShm no Wine (evita erro MIT-SHM no Docker)
    && box86 wine reg add "HKCU\\Software\\Wine\\X11 Driver" \
       /v "UseXShm" /t REG_SZ /d "N" /f || true \
    # Limpeza total na mesma camada - nao deixa rastro
    && rm -rf /tmp/wine-install \
    && apt-get remove -y wget gnupg \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf \
       /var/cache/apt/archives/* \
       /var/lib/apt/lists/* \
       /usr/share/doc/* \
       /usr/share/man/* \
       /usr/share/locale/* \
       /root/.cache \
       /tmp/*

# Variaveis de ambiente padrao
ENV DISPLAY=:0
ENV PULSE_SERVER=unix:/run/user/1000/pulse/native

WORKDIR /games
