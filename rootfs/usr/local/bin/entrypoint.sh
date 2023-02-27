#!/bin/ash
  if [ -z "${ICS_IP}" ]; then ICS_IP=0.0.0.0; fi
  if [ -z "${ICS_PORT}" ]; then ICS_PORT=5000; fi
  if [ -z "${ICS_WORKERS}" ]; then ICS_WORKERS=4; fi

  if [ -z "${1}" ]; then
    cd /ics/bin
    set -- "gunicorn" \
      -w ${ICS_WORKERS} \
      -b ${ICS_IP}:${ICS_PORT} \
      app:app
  fi

  exec "$@"