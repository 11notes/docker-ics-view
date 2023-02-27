# :: Build
  FROM python:3.11-alpine as base
  ENV checkout=v1.4

  RUN set -ex; \
    apk add --update --no-cache \
      curl \
      wget \
      unzip \
      build-base \
      linux-headers \
      make \
      cmake \
      g++ \
      git; \
    git clone https://github.com/niccokunzmann/open-web-calendar.git; \
    cd /open-web-calendar; \
    git checkout ${checkout};

# :: Header
  FROM python:3.11-alpine
  COPY --from=base /open-web-calendar/ /ics/bin

# :: Run
  USER root

  # :: prepare
    RUN set -ex; \
      apk add --update --no-cache \
        shadow; \
      mkdir -p /ics/bin/static/etc; \
      ln -s /ics/bin/static/etc /ics/etc;

    RUN set -ex; \
      addgroup --gid 1000 -S ics; \
      adduser --uid 1000 -D -S -h /ics -s /sbin/nologin -G ics ics;

  # :: install
    RUN set -ex; \
    cd /ics/bin; \
    pip install --upgrade --no-cache-dir -r requirements.txt;

  # :: copy root filesystem changes
    COPY ./rootfs /

  # :: docker -u 1000:1000 (no root initiative)
    RUN set -ex; \
      chown -R ics:ics \
      /ics

# :: Volumes
  VOLUME ["/ics/etc"]

# :: Start
  RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
  USER ics
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]