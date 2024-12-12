FROM lscr.io/linuxserver/oscam:latest

# RUN curl -s -o /tmp/oscam-emu.patch https://raw.githubusercontent.com/oscam-emu/oscam-emu/refs/heads/master/oscam-emu.patch
# COPY /oscam-emu.patch /tmp/oscam-emu.patch
RUN curl -s -o /tmp/oscam-emu.patch https://raw.githubusercontent.com/oscam-mirror/oscam-emu-patch/refs/heads/master/oscam-emu.patch

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
  build-base \
  libdvbcsa-dev \
  libusb-dev \
  linux-headers \
  openssl-dev \
  pcsc-lite-dev \
  git

RUN \
  echo "**** clone oscam ****" && \
  mkdir -p /tmp/oscam && \
  git clone https://git.streamboard.tv/common/oscam.git /tmp/oscam

RUN \
  echo "**** patch oscam ****" && \
  cd /tmp/oscam && \
  git apply /tmp/oscam-emu.patch

RUN \
  echo "**** compile oscam ****" && \
  cd /tmp/oscam && \
  ./config.sh \
  --enable all \
  --disable \
  CARDREADER_DB2COM \
  CARDREADER_INTERNAL \
  CARDREADER_STINGER \
  CARDREADER_STAPI \
  CARDREADER_STAPI5 \
  IPV6SUPPORT \
  LCDSUPPORT \
  LEDSUPPORT \
  READ_SDT_CHARSETS && \
  make \
  CONF_DIR=/config \
  DEFAULT_PCSC_FLAGS="-I/usr/include/PCSC" \
  NO_PLUS_TARGET=1 \
  OSCAM_BIN=/usr/bin/oscam \
  pcsc-libusb

RUN \
  echo "**** cleanup ****" && \
  apk del --purge \
  build-dependencies && \
  rm -rf \
  /tmp/*