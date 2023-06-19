/* This is used by the dhtmlx scheduler.
 *
 */

function escapeHtml(unsafe) {
  // from https://stackoverflow.com/a/6234804
  return unsafe
       .replace(/&/g, "&amp;")
       .replace(/</g, "&lt;")
       .replace(/>/g, "&gt;")
       .replace(/"/g, "&quot;")
       .replace(/'/g, "&#039;");
}

function getQueries() {
  // from http://stackoverflow.com/a/1099670/1320237
  var qs = document.location.search;
  var tokens, re = /[?&]?([^=]+)=([^&]*)/g;
  qs = qs.split("+").join(" ");

  var queries = {};
  while (tokens = re.exec(qs)) {
      var id = decodeURIComponent(tokens[1]);
      var content = decodeURIComponent(tokens[2]);
      if (Array.isArray(queries[id])) {
          queries[id].push(content);
      } if (queries[id]) {
          queries[id] = [queries[id], content];
      } else {
          queries[id] = content;
      }
  }
  return queries;
}

// TODO: allow choice through specification
var GOOGLE_URL = "https://maps.google.com/maps?q=";
var OSM_URL = "https://www.openstreetmap.org/search?query=";

/* Create a link around the HTML text.
* Use this instead of creating links manually because it also sets the
* target according to the specification.
*/
function makeLink(url, html) {
return "<a target='" + specification.target + "' href='" + escapeHtml(url) + "'>" + html + "</a>";
}

var template = {
  "summary": function(event) {
      return "<div class='summary'>" +
        (event.url ? makeLink(event.url, event.text) : event.text) +
        "</div>";
  },
  "details": function(event) {
      return "<div class='details'>" + event.description + "</div>";
  },
  "location": function(event) {
      if (!event.location && !event.geo) {
          return "";
      }
      var text = event.location || "🗺";
      var geoUrl;
      if (event.geo) {
          geoUrl = "https://www.openstreetmap.org/?mlon=" + event.geo.lon + "&mlat=" + event.geo.lat + "&#map=15/" + event.geo.lat + "/" + event.geo.lon;
      } else {
          geoUrl = OSM_URL + encodeURIComponent(event.location);
      }
      return makeLink(geoUrl, text);
  },
  "debug": function(event) {
      return "<pre class='debug' style='display:none'>" +
          JSON.stringify(event, null, 2) +
          "</pre>"
  }
}

/* The files use a Scheduler variable.
* scheduler.locale is used to load the locale.
* This creates the required interface.
*/
var setLocale = function(){};
var Scheduler = {plugin:function(setLocale_){
  // this is called by the locale_??.js files.
  setLocale = setLocale_;
}};

function showError(element) {
  var icon = document.getElementById("errorStatusIcon");
  icon.classList.add("onError");
  var errors = document.getElementById("errorWindow");
  element.classList.add("item");
  errors.appendChild(element);
}

function toggleErrorWindow() {
  var scheduler_tag = document.getElementById("scheduler_here");
  var errors = document.getElementById("errorWindow");
  scheduler_tag.classList.toggle("hidden");
  errors.classList.toggle("hidden");
}

function showXHRError(xhr) {
  var iframe = document.createElement("iframe");
  iframe.srcdoc = xhr.responseText;
  iframe.className = "errorFrame";
  showError(iframe);
}

function showEventError(error) {
  // show an error created by app.py -> error_to_dhtmlx
  var div = document.createElement("div");
  div.innerHTML = "<h1>" + error.text + "</h1>" + 
      "<a href='" + error.url + "'>" + error.url + "</a>" +
      "<p>" + error.description + "</p>" + 
      "<pre>" + error.traceback + "</pre>";
  showError(div);
}

function disableLoader() {
  var loader = document.getElementById("loader");
  loader.classList.add("hidden");
}

function setLoader() {
  if (specification.loader) {
      var loader = document.getElementById("loader");
      var url = specification.loader.replace(/'/g, "%27");
      loader.style.cssText += "background:url('" + url + "') center center no-repeat;"
  } else {
      disableLoader();
  }
}

function loadCalendar() {
  var format = scheduler.date.date_to_str("%H:%i");
  setLocale(scheduler);
  // load plugins, see https://docs.dhtmlx.com/scheduler/migration_from_older_version.html#5360
  scheduler.plugins({
      agenda_view: true,
      multisource: true,
      quick_info: true,
      recurring: false,
      tooltip: true,
      readonly: true,
  });
  // set format of dates in the data source
  scheduler.config.xml_date="%Y-%m-%d %H:%i";
  // use UTC, see https://docs.dhtmlx.com/scheduler/api__scheduler_server_utc_config.html
  // scheduler.config.server_utc = true; // we use timezones now
  
  scheduler.config.readonly = true;
  // set the start of the week. See https://docs.dhtmlx.com/scheduler/api__scheduler_start_on_monday_config.html
  scheduler.config.start_on_monday = specification["start_of_week"] == "mo";
  let hour_division = parseInt(specification["hour_division"]);
  scheduler.config.hour_size_px = 44 * hour_division;
  scheduler.templates.hour_scale = function(date){
var step = 60 / hour_division;
var html = "";
for (var i=0; i<hour_division; i++){
    html += "<div style='height:44px;line-height:44px;'>"+format(date)+"</div>"; // TODO: This should be in CSS.
    date = scheduler.date.add(date, step, "minute");
}
return html;
  }
  scheduler.config.first_hour = parseInt(specification["starting_hour"]);
  scheduler.config.last_hour = parseInt(specification["ending_hour"]);
  var date = specification["date"] ? new Date(specification["date"]) : new Date();
  scheduler.init('scheduler_here', date, specification["tab"]);

  // event in the calendar
  scheduler.templates.event_bar_text = function(start, end, event){
      return event.text;
  }
  // tool tip
  // see https://docs.dhtmlx.com/scheduler/tooltips.html
  scheduler.templates.tooltip_text = function(start, end, event) {
      return template.summary(event) + template.details(event) + template.location(event);
  };
  scheduler.tooltip.config.delta_x = 1;
  scheduler.tooltip.config.delta_y = 1;
  // quick info
  scheduler.templates.quick_info_title = function(start, end, event){
      return template.summary(event);
  }
  scheduler.templates.quick_info_content = function(start, end, event){
      return template.details(event) +
          template.location(event) +
          template.debug(event);
  }

  scheduler.templates.event_header = function(start, end, event){
      if (event.categories){
          return (scheduler.templates.event_date(start)+" - "+
              scheduler.templates.event_date(end)+'<b> | '+
        event.categories)+' |</b>'
      } else {
          return(scheduler.templates.event_date(start)+" - "+
          scheduler.templates.event_date(end))
      }
  };

  // general style
  scheduler.templates.event_class=function(start,end,event){
      if (event.type == "error") {
          showEventError(event);
      }
      return event.type;
  };
  
  // set agenda date
  scheduler.templates.agenda_date = scheduler.templates.month_date;

  // START CHANGE by https://github.com/11notes
  schedulerUrl = `/calendar.events.json${document.location.search}`;
  if(!(/\?/i.test(schedulerUrl))){
    schedulerUrl += '?';
  }
  // add the time zone if not specified
  if (specification.timezone == "") {
      schedulerUrl += "&timezone=" + getTimezone();
  }
  // END CHANGE by https://github.com/11notes
      
  scheduler.attachEvent("onLoadError", function(xhr) {
      disableLoader();
      console.log("could not load events");
      console.log(xhr);
      showXHRError(xhr);
  });

  scheduler.attachEvent("onXLE", disableLoader);


  //requestJSON(schedulerUrl, loadEventsOnSuccess, loadEventsOnError);
  scheduler.setLoadMode("day");
  scheduler.load(schedulerUrl, "json");
  

  //var dp = new dataProcessor(schedulerUrl);
  // use RESTful API on the backend
  //dp.setTransactionMode("REST");
  //dp.init(scheduler);
  
  setLoader();
}

/* Agenda view
*
* see https://docs.dhtmlx.com/scheduler/agenda_view.html
*/

scheduler.date.agenda_start = function(date){
return scheduler.date.month_start(new Date(date)); 
};

scheduler.date.add_agenda = function(date, inc){
return scheduler.date.add(date, inc, "month"); 
};

window.addEventListener("load", loadCalendar);

