# :: Build
  FROM python:3.11-alpine as build
  ENV APP_VERSION=v1.13

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
    git checkout ${APP_VERSION};

# :: Header
  FROM python:3.11-alpine
  ENV APP_ROOT=/ics
  COPY --from=build /open-web-calendar/ ${APP_ROOT}/bin

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk --update --no-cache add \
        curl \
        tzdata \
        shadow; \
      apk update; \
      apk upgrade;

  # :: create user
    RUN set -ex; \
      addgroup --gid 1000 -S docker; \
      adduser --uid 1000 -D -S -h / -s /sbin/nologin -G docker docker;

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/bin/static/etc; \
      ln -s ${APP_ROOT}/bin/static/etc ${APP_ROOT}/etc;

  # :: install application
    RUN set -ex; \
      cd ${APP_ROOT}/bin; \
      pip install --upgrade --no-cache-dir -r requirements.txt;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: modify application
    COPY ./build ${APP_ROOT}/bin
    RUN set -ex; \
      cd ${APP_ROOT}/bin; \
      sed -i 's#<a class="item" id="infoIcon".\+</a>##' ./templates/calendars/dhtmlx.html; \
      sed -i 's#DEBUG = os.environ.get("APP_DEBUG", "true").lower() == "true"#DEBUG = os.environ.get("ICS_DEBUG", "false").lower() == "false"#' ./app.py; \
      sed -i 's#PORT = int(os.environ.get("PORT", "5000"))#PORT = int(os.environ.get("ICS_PORT", "5000"))#' ./app.py; \
      sed -i 's#CACHE_REQUESTED_URLS_FOR_SECONDS = int(os.environ.get("CACHE_REQUESTED_URLS_FOR_SECONDS", 600))#CACHE_REQUESTED_URLS_FOR_SECONDS = int(os.environ.get("ICS_CACHE_LIFETIME", 60))#' ./app.py; \
      sed -i 's#DEFAULT_SPECIFICATION_PATH = os.path.join(HERE, "default_specification.yml")#DEFAULT_SPECIFICATION_PATH = os.path.join(HERE, "static", "etc", "default.json")#' ./app.py; \
      sed -i 's#PARAM_SPECIFICATION_URL = "specification_url"#PARAM_SPECIFICATION_URL = "calendar"#' ./app.py;

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc"]

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]