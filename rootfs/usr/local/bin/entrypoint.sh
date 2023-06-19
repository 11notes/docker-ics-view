#!/bin/ash
  if [ -z "${ICS_IP}" ]; then ICS_IP=0.0.0.0; fi
  if [ -z "${ICS_PORT}" ]; then ICS_PORT=5000; fi
  if [ -z "${ICS_WORKERS}" ]; then ICS_WORKERS=4; fi

  # DHTMLX plugins
  if [ -z "${ICS_VIEW_DHTMLX_ENABLE_PLUGINS}" ]; then ICS_VIEW_DHTMLX_ENABLE_PLUGINS="agenda_view multisource quick_info tooltip readonly all_timed"; fi
  if [ -z "${ICS_VIEW_DHTMLX_DISABLE_PLUGINS}" ]; then ICS_VIEW_DHTMLX_DISABLE_PLUGINS=""; fi

  ICS_VIEW_DHTMLX_PLUGINS=""

  for PLUGIN in ${ICS_VIEW_DHTMLX_ENABLE_PLUGINS}; do
    ICS_VIEW_DHTMLX_PLUGINS="${ICS_VIEW_DHTMLX_PLUGINS}${PLUGIN}:true,"
  done

  for PLUGIN in ${ICS_VIEW_DHTMLX_DISABLE_PLUGINS}; do
    ICS_VIEW_DHTMLX_PLUGINS="${ICS_VIEW_DHTMLX_PLUGINS}${PLUGIN}:false,"
  done

  cp /ics/bin/static/js/configure.js.bkp /ics/bin/static/js/configure.js
  sed -i "s/\$ICS_VIEW_DHTMLX_PLUGINS/${ICS_VIEW_DHTMLX_PLUGINS}/" /ics/bin/static/js/configure.js

  if [ -z "${1}" ]; then
    cd /ics/bin
    set -- "gunicorn" \
      -w ${ICS_WORKERS} \
      -b ${ICS_IP}:${ICS_PORT} \
      app:app
  fi

  exec "$@"