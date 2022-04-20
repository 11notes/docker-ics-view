# :: Header
	FROM python:3.9-alpine

# :: Run
	USER root

	# :: prepare
		RUN set -ex; \
			apk add --update --no-cache \
				shadow;

		RUN set -ex; \
			addgroup --gid 1000 -S ics; \
			adduser --uid 1000 -D -S -h /ics -s /sbin/nologin -G ics ics;

    # :: copy root filesystem changes
        COPY ./rootfs /

	# :: install
		RUN set -ex; \
			cd /ics; \
			pip install -r requirements.txt;


    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R ics:ics \
				/ics

# :: Volumes
	VOLUME ["/ics/static/etc"]

# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER ics
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]