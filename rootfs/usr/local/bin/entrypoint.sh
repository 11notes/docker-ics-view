#!/bin/ash
cd /ics
set -- "python3" \
        app.py
exec "$@"