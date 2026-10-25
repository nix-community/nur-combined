// SPDX-License-Identifier: MIT
// Expand cached iCalendar records with libical; no network or calendar writes.
#include <libical/ical.h>
#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTextStream>
#include <QFile>
#include <memory>
#include <map>
#include <vector>
#include <string>
#include <stdexcept>

using Root = std::unique_ptr<icalcomponent, decltype(&icalcomponent_free)>;
struct Event { icalcomponent *root; icalcomponent *event; std::string key; };
struct Busy { QJsonArray rows; bool overflow = false; bool allDay = false; const icaltimezone *local = nullptr; };
static void occurrence(icalcomponent *, const icaltime_span *span, void *data) {
    auto &busy = *static_cast<Busy *>(data);
    if (busy.rows.size() >= 10000) { busy.overflow = true; return; }
    // Transparency and cancellation are handled before expansion. Missing
    // TRANSP is opaque under iCalendar, even if libical's span flag is false.
    auto start=span->start,end=span->end;
    if (busy.allDay) {
        auto a=icaltime_from_timet_with_zone(start,0,icaltimezone_get_utc_timezone());
        auto b=icaltime_from_timet_with_zone(end,0,icaltimezone_get_utc_timezone());
        a.zone=busy.local;b.zone=busy.local;
        start=icaltime_as_timet_with_zone(a,busy.local);end=icaltime_as_timet_with_zone(b,busy.local);
    }
    if (end > start) busy.rows.append(QJsonArray{double(start), double(end)});
}
static bool cancelled(icalcomponent *event) {
    return icalcomponent_get_status(event) == ICAL_STATUS_CANCELLED;
}
static void zones(icalcomponent *root, icalcomponent *event, const icaltimezone *local) {
    for (auto kind : {ICAL_DTSTART_PROPERTY, ICAL_DTEND_PROPERTY, ICAL_RECURRENCEID_PROPERTY, ICAL_EXDATE_PROPERTY, ICAL_RDATE_PROPERTY}) {
        for (auto prop = icalcomponent_get_first_property(event, kind); prop; prop = icalcomponent_get_next_property(event, kind)) {
            if (kind == ICAL_RECURRENCEID_PROPERTY && icalproperty_get_parameter_as_string(prop, "RANGE"))
                throw std::runtime_error("A recurrence with RANGE is not supported; availability was not computed");
            auto t = kind == ICAL_DTSTART_PROPERTY ? icalproperty_get_dtstart(prop) :
                     kind == ICAL_DTEND_PROPERTY ? icalproperty_get_dtend(prop) :
                     kind == ICAL_RECURRENCEID_PROPERTY ? icalproperty_get_recurrenceid(prop) :
                     kind == ICAL_EXDATE_PROPERTY ? icalproperty_get_exdate(prop) : icalproperty_get_rdate(prop).time;
            if (kind == ICAL_RDATE_PROPERTY && icaltime_is_null_time(t))
                throw std::runtime_error("RDATE periods are not supported; availability was not computed");
            if (icaltime_is_null_time(t) || !icaltime_is_valid_time(t))
                throw std::runtime_error("A calendar contains an invalid date");
            const auto tzid = icalproperty_get_parameter_as_string(prop, "TZID");
            if (tzid) {
                const icaltimezone *zone = icalcomponent_get_timezone(root, tzid);
                if (!zone) zone = icaltimezone_get_builtin_timezone(tzid);
                if (!zone) zone = icaltimezone_get_builtin_timezone_from_tzid(tzid);
                if (!zone) throw std::runtime_error("A calendar timezone could not be resolved");
                t.zone = zone;
            } else if (!t.zone && !t.is_date) {
                t.zone = local;
                const auto location=icaltimezone_get_location(local);
                icalproperty_set_parameter_from_string(prop,"TZID",location ? location : "UTC");
            }
            switch (kind) {
                case ICAL_DTSTART_PROPERTY: icalproperty_set_dtstart(prop, t); break;
                case ICAL_DTEND_PROPERTY: icalproperty_set_dtend(prop, t); break;
                case ICAL_RECURRENCEID_PROPERTY: icalproperty_set_recurrenceid(prop, t); break;
                case ICAL_EXDATE_PROPERTY: icalproperty_set_exdate(prop, t); break;
                case ICAL_RDATE_PROPERTY: {auto value=icalproperty_get_rdate(prop);value.time=t;icalproperty_set_rdate(prop,value);break;}
                default: break;
            }
        }
    }
}
int main(int argc, char **argv) {
    QCoreApplication app(argc,argv);
    try {
        QFile input; if (!input.open(stdin, QIODevice::ReadOnly)) throw std::runtime_error("Could not read calendar input"); const auto bytes=input.read(1048577);
        if (bytes.size()>1048576) throw std::runtime_error("Calendar input exceeds 1 MiB");
        QJsonParseError error;const auto document=QJsonDocument::fromJson(bytes,&error);
        if (error.error!=QJsonParseError::NoError || !document.isObject()) throw std::runtime_error("Invalid calendar input");
        const auto request=document.object();const auto records=request["items"].toArray();
        const auto start=qint64(request["start"].toDouble()),end=qint64(request["end"].toDouble());
        if (records.size()>2000 || start<=0 || end<=start || end-start>8*86400) throw std::runtime_error("Invalid calendar range or event limit");
        const auto zoneName=request["timezone"].toString().toUtf8();
        const icaltimezone *local=zoneName=="UTC" ? icaltimezone_get_utc_timezone() : icaltimezone_get_builtin_timezone(zoneName.constData());
        if (!local) throw std::runtime_error("The local timezone could not be resolved");
        std::vector<Root> roots;std::vector<Event> events;
        for (const auto record : records) {
            const auto item=record.toObject();const auto payload=item["payload"].toString().toUtf8();
            if (payload.isEmpty() || payload.size()>65536) throw std::runtime_error("A cached event payload is missing or too large");
            Root root(icalcomponent_new_from_string(payload.constData()),icalcomponent_free);
            if (!root || icalcomponent_count_errors(root.get())) throw std::runtime_error("A cached calendar record is invalid");
            std::vector<icalcomponent *> children;
            if (icalcomponent_isa(root.get())==ICAL_VEVENT_COMPONENT) children.push_back(root.get());
            else for (auto e=icalcomponent_get_first_component(root.get(),ICAL_VEVENT_COMPONENT);e;e=icalcomponent_get_next_component(root.get(),ICAL_VEVENT_COMPONENT)) children.push_back(e);
            for (auto event : children) {
                const auto uid=icalcomponent_get_uid(event);if (!uid || !*uid) throw std::runtime_error("A cached event has no UID");
                zones(root.get(),event,local);
                if (!cancelled(event) && icaltime_is_null_time(icalcomponent_get_dtstart(event))) throw std::runtime_error("An event has no start time");
                events.push_back({root.get(),event,item["collection"].toString().toStdString()+"\n"+uid});
            }
            roots.push_back(std::move(root));
        }
        std::map<std::string,icalcomponent *> masters;
        for (const auto &e:events) if (!icalcomponent_get_first_property(e.event,ICAL_RECURRENCEID_PROPERTY)) {
            auto old=masters.find(e.key);
            if (old!=masters.end()) throw std::runtime_error("Duplicate calendar series; availability was not computed");
            masters[e.key]=e.event;
        }
        for (const auto &e:events) if (icalcomponent_get_first_property(e.event,ICAL_RECURRENCEID_PROPERTY)) {
            auto master=masters.find(e.key);
            if (master==masters.end()) throw std::runtime_error("A recurrence exception has no cached master; availability was not computed");
            if (master!=masters.end()) icalcomponent_add_property(master->second,icalproperty_new_exdate(icalcomponent_get_recurrenceid(e.event)));
        }
        Busy busy;busy.local=local;
        for (const auto &e:events) {
            const auto transparency=icalcomponent_get_first_property(e.event,ICAL_TRANSP_PROPERTY);
            if (cancelled(e.event) || (transparency && icalproperty_get_transp(transparency)==ICAL_TRANSP_TRANSPARENT)) continue;
            auto master=masters.find(e.key);if (master!=masters.end() && cancelled(master->second)) continue;
            busy.allDay=icalcomponent_get_dtstart(e.event).is_date;
            icalcomponent_foreach_recurrence(e.event,icaltime_from_timet_with_zone(start-(busy.allDay ? 2*86400 : 0),0,icaltimezone_get_utc_timezone()),icaltime_from_timet_with_zone(end+(busy.allDay ? 2*86400 : 0),0,icaltimezone_get_utc_timezone()),occurrence,&busy);
            if (busy.overflow) throw std::runtime_error("Too many calendar occurrences; availability was not computed");
        }
        QTextStream(stdout)<<QJsonDocument(QJsonObject{{"busy",busy.rows}}).toJson(QJsonDocument::Compact)<<'\n';return 0;
    } catch (const std::exception &error) { QTextStream(stderr)<<error.what()<<'\n';return 2; }
}
