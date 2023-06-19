# Alpine :: ics-View
Run an ics calendar webview based on Alpine Linux. Small, lightweight, secure and fast 🏔️

![Calendar View](screenshots/default.json.png?raw=true "Calendar View (default.json)")

## Volumes
* **/ics/etc** - Directory of json configuration files for different views

## Run
```shell
docker run --name ics-view \
  -v .../etc:/ics/etc \
  -d 11notes/ics-view:[tag]
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |

## Environment
| Parameter | Value | Default |
| --- | --- | --- |
| `ICS_IP` | localhost or 127.0.0.1 or a dedicated IP | 0.0.0.0 |
| `ICS_PORT` | any port > 1024 | 5000 |
| `ICS_MAX_PER_VIEW` | How many calendars (*.ics feeds) are allowed to be loaded at once | 5 |
| `ICS_WORKERS` | How many workers should be started to handle requests | 4 |
| `ICS_CACHE_LIFETIME` | How long *.ics feed are cached between requests in seconds | 60 |
| `ICS_VIEW_DHTMLX_ENABLE_PLUGINS` | Enabled DHTMLX plugins | "agenda_view multisource quick_info tooltip readonly" |
| `ICS_VIEW_DHTMLX_DISABLE_PLUGINS` | Disabled DHTMLX plugins | "" |
| `ICS_DEBUG` | Enable debug mode | false |

## Configuration
You can place different configuration json files in /ics/etc and use the directly via URL (you do not need to add .json, just the file name)
```shell
http://localhost:5000/?calendar=demo // will use demo.json in /ics/etc
http://localhost:5000/?calendar=https://domain.com/foo/demo.json
```

## DHTMLX Plugins
You can find a list of all available plugins [here](https://docs.dhtmlx.com/scheduler/extensions_list.html).
To use additional plugins simply add them to the desired environment variable. The example will add the plugin all_timed and year_view and remove the plugin recurring from being used.

```shell
docker run --name ics-view \
  -v .../etc:/ics/etc \
  -e ICS_VIEW_DHTMLX_ENABLE_PLUGINS="agenda_view multisource quick_info tooltip readonly all_timed year_view" \
  -e ICS_VIEW_DHTMLX_DISABLE_PLUGINS="recurring" \
  -d 11notes/ics-view:[tag]
```

# CSS tricks
If you add ?calendarID=NAME at the end of the URL of your *.ics calendar you can use this NAME in a css selector to colour each *.ics calendar differently
```css
[event_id^="christian"],
[event_id^="christian"] div {background-color:#FF0000 !important; color:#FFFFFF !important;}
```

## Parent
* [python:3.11-alpine](https://github.com/docker-library/python/blob/b744d9708a2fb8e2295198ef146341c415e9bc28/3.11/alpine3.18/Dockerfile)

## Built with
* [open-web-calendar](https://github.com/niccokunzmann/open-web-calendar)
* [DHTMLX Scheduler](https://dhtmlx.com/docs/products/dhtmlxScheduler)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy
* [Permanent Stroage](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS and more