#!/bin/ash
  if [ -z "$1" ]; then
    cd /ics/bin
    set -- "gunicorn" \
      -w 4 \
      -b 0.0.0.0:5000 \
      app:app
  fi

  exec "$@"