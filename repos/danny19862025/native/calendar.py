"""Small JSON bridge to the calendars used by GNOME Calendar/Evolution."""
import json
import sys


def main():
    import gi
    gi.require_version('ECal', '2.0')
    gi.require_version('EDataServer', '1.2')
    from gi.repository import ECal, EDataServer
    # ECal imports the libical namespace version installed on this system.
    from gi.repository import ICalGLib

    request = json.loads(sys.stdin.read(65537))
    registry = EDataServer.SourceRegistry.new_sync(None)
    sources = [s for s in registry.list_sources(EDataServer.SOURCE_EXTENSION_CALENDAR)
               if s.get_enabled()]
    operation = request['operation']
    if operation == 'calendars':
        default = registry.ref_default_calendar()
        return [dict(id=s.get_uid(), name=s.get_display_name(),
                     default=bool(default and s.get_uid() == default.get_uid()))
                for s in sources[:100]
                if s.get_extension(EDataServer.SOURCE_EXTENSION_CALENDAR).get_backend_name()
                not in ('contacts', 'weather', 'webcal')]
    if operation == 'create':
        source = next((s for s in sources if s.get_uid() == request['calendar']), None)
        if source is None:
            raise ValueError('This calendar is no longer available; reopen the event form')
        client = ECal.Client.connect_sync(source, ECal.ClientSourceType.EVENTS, 5, None)
        if client.is_readonly():
            raise ValueError('This calendar is read-only; choose another calendar')
        component = ICalGLib.Component.new_from_string(request['ical'])
        if component is None or component.is_valid() is False:
            raise ValueError('The event could not be converted to a calendar entry')
        ok, uid = client.create_object_sync(component, ECal.OperationFlags.NONE, None)
        if not ok:
            raise ValueError('The calendar did not accept the event')
        return dict(uid=uid, calendar=source.get_display_name())
    if operation == 'search':
        if request.get('calendar'):
            sources = [s for s in sources if s.get_uid() == request['calendar']]
        query = request.get('query', '')
        if len(query) > 512:
            raise ValueError('Calendar search is limited to 512 characters')
        # EDS expressions use quoted strings; JSON string escaping handles literals.
        expression = '(contains? "any" ' + json.dumps(query, ensure_ascii=False) + ')'
        records, errors, budget = [], [], 0
        for source in sources[:20]:
            try:
                client = ECal.Client.connect_sync(source, ECal.ClientSourceType.EVENTS, 1, None)
                ok, objects = client.get_object_list_sync(expression, None)
                if not ok:
                    continue
                for component in objects[:60]:
                    payload = component.as_ical_string()
                    if len(payload.encode()) > 65536:
                        continue
                    budget += len(payload.encode()) + 2048
                    if budget > 850000 or len(records) >= 100:
                        break
                    records.append(dict(payload=payload, collection=source.get_display_name(),
                                        uri=''))
            except Exception as error:
                errors.append(str(error)[:240])
            if budget > 850000 or len(records) >= 100:
                break
        if not records and errors:
            raise ValueError(errors[0])
        return records
    raise ValueError('Unknown calendar operation')


if __name__ == '__main__':
    try:
        print(json.dumps(main(), ensure_ascii=False))
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
