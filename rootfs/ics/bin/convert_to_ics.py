import datetime
from icalendar import Event, Calendar, Timezone
from icalendar.prop import vDDDTypes
from flask import Response
from conversion_base import ConversionStrategy

class ConvertToICS(ConversionStrategy):
    """Convert events to dhtmlx. This conforms to a stratey pattern."""
    
    def created(self):
        self.title = self.specification["title"]
        self.timezones = set() # ids
        
    def is_event(self, component):
        """Whether a component is an event."""
        return isinstance(component, Event)

    def is_timezone(self, component):
        """Whether a component is an event."""
        return isinstance(component, Timezone)

    def collect_components_from(self, calendars):
        for calendar in calendars:
            for component in calendar.walk():
                if self.is_event(component):
                    with self.lock:
                        self.components.append(component)
                if self.is_timezone(component):
                    tzid = component.get("TZID")
                    if tzid and tzid not in self.timezones:
                        with self.lock:
                            self.components.append(component)
                            self.timezones.add(tzid)

    def convert_error(self, error, url, tb_s):
        """Create an error which can be used by the dhtmlx scheduler."""
        event = Event()
        event["DTSTART"] = event["DTEND"] = vDDDTypes(datetime.datetime.now())
        event["SUMMARY"] = type(error).__name__
        event["DESCRIPTION"] = str(error) + "\n\n" + tb_s
        event["UID"] = "error" + str(id(error))
        if url:
            event["URL"] = url
        return event
    
    def create_calendar(self):
        calendar = Calendar()
        calendar["VERSION"] = "2.0"
        calendar["PRODID"] = "open-web-calendar"
        calendar["CALSCALE"] = "GREGORIAN"
        calendar["METHOD"] = "PUBLISH"
        calendar["X-WR-CALNAME"] = self.title
        return calendar
    
    def merge(self):
        calendar = self.create_calendar()
        for event in self.components:
            calendar.add_component(event)
        return Response(calendar.to_ical(), mimetype="text/calendar")

