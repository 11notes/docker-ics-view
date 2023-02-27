# docker-ics-view
View *.ics feeds from your favorite sources directly online on a simple web UI.

![Calendar View](screenshots/default.json.png?raw=true "Calendar View (default.json)")

## Volumes
* **/ics/etc** - Configuration files for different calendar views

## Run
```shell
docker run --name ics-view \
    -v volume-etc:/ics/etc \
    -d 11notes/ics-view:[tag]
```

## Environment Variables
* **ICS_IP** (*default: 0.0.0.0*) - IP of the webserver
* **ICS_PORT** (*default: 5000*) - TCP port of the webserver
* **ICS_MAX_PER_VIEW** (*default: 5*) - How many calendars (*.ics feeds) are allowed to be loaded at once
* **ICS_WORKERS** (*default: 4*) - How many workers should be started to handle requests
* **ICS_CACHE_LIFETIME** (*default: 60*) - How long *.ics feed are cached between requests
* **ICS_DEBUG** (*default: false*) - Enable debug mode

## Warning
You need to run this container behind a nginx server to terminate TLS/SSL. Do not expose this container by any means to the world wide web without using a proxy for access control, ingress limits, and so on!

## Config
You can place different configuration json files in /ics/etc and use the directly via URL (you do not need to add .json, just the file name)
```shell
http://localhost:5000/?calendar=demo // will use demo.json in /ics/etc
or
http://localhost:5000/?calendar=https://domain.com/foo/demo.json
```
Please refer to niccokunzmann for the configuration of the json file (the default.json contains most settings already)

## Cofig YAML (just convert to json)
```shell
## Specification
##
## The specification of the calendar can be written in YAML and JSON.
## You can copy and paste the specification and adapt it to your needs.
##
## Lines with two ## are comments and lines with one # are code which
## is not in use.
##

## url can be a single link to an ics file or a list.
#url: https://your.link.to/a-file.ics
url:
- https://www.calendarlabs.com/ical-calendar/ics/46/Germany_Holidays.ics
#- https://www.calendarlabs.com/ical-calendar/ics/46/Germany_Holidays.ics
#- https://www.calendarlabs.com/ical-calendar/ics/46/Germany_Holidays.ics

## The title is displayed as the title of the html page.
title: "Open Web Calendar"

## The language of the calendar. You can choose from these languages:
## Arabic: "ar"
## Belarusian: "be"
## Catalan: "ca"
## Chinese: "cn"
## Czech: "cs"
## Danish: "da"
## Dutch: "nl"
## English: "en"
## Finnish: "fi"
## French: "fr"
## German: "de"
## Greek: "el"
## Hebrew: "he"
## Hungarian: "hu"
## Indonesian: "id"
## Italian: "it"
## Japanese: "jp"
## Norwegian: "no"
## Norwegian Bokmål: "nb"
## Polish: "pl"
## Portuguese: "pt"
## Romanian: "ro"
## Russian: "ru"
## Slovak: "sk"
## Slovenian: "si"
## Spanish: "es"
## Swedish: "sv"
## Turkish: "tr"
## Ukrainian: "ua"
language: "en"

## The skin changes the look of the calendar.
## They are located in the static/css/dhtmlx folder.
## You can choose one of these:
#skin: "dhtmlxscheduler_contrast_black.css"
#skin: "dhtmlxscheduler_terrace.css"
#skin: "dhtmlxscheduler_contrast_white.css"
#skin: "dhtmlxscheduler_flat.css"
skin: "dhtmlxscheduler_material.css"

## You can embed custom css code, i.e. to change the background or font.
css: ""

## The target is the place where links are opened.
## "_top" opens the link where the website is embedded.
## "_blank" opens the link in a new tab.
## "_self" replaces the calendar with the link content.
## "_parent" opens the link in on the page where the calendar is embedded.
target: "_top"

## This is the url to a loader animation which is displayed while the
## calendar loads events.
loader: "/img/loaders/circular-loader.gif"

## Choose which tab to display when the calendar opens.
tab: "month"
#tab: "week"
#tab: "day"
#tab: "agenda"

## Choose which tabs can be chosen by the user.
tabs:
- "month"
- "week"
- "day"
#- agenda

## Users can control the calendar.
## You can hide these buttons:
controls:
## Users can go to the next day/week/month.
- "next"
## Users can go to the previous day/week/month.
- "previous"
## Users can go to the current day/week/month.
- "today"
## Users can see the date.
- "date"

## You can describe the calendar with a text so people know what it is about.
description: "This is a calendar which provides a website and an ICS subscription link based on the different calendars it is configured to use."

###################### You will probably not change this. ######################
##
## The template is the file which shows the calendar.
## It is located in the templates/calendars folder.
template: "dhtmlx.html"

## This is set by the dhtmlscheduler when the events are displayed.
timeshift: 0
```

# CSS tricks
If you add ?calendarID=NAME at the end of the URL of your *.ics calendar you can use this NAME in a css selector to colour each *.ics calendar differently
```shell
[event_id^="christian"],[event_id^="christian"] div {background-color: #FF0000 !important;color: #FFFFFF !important;}
```

## Docker -u 1000:1000 (no root initiative)
As part to make containers more secure, this container will not run as root, but as uid:gid 1000:1000. Therefore the default TCP port is 5000.

## Build with
* [open-web-calendar](https://github.com/niccokunzmann/open-web-calendar) - Flask to use *.ics feeds
* [DHTMLX Scheduler](https://dhtmlx.com/docs/products/dhtmlxScheduler/) - DHTMLX javascript libraries for scheduler

## Tips
* [Permanent Storge with NFS/CIFS/...](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS/...