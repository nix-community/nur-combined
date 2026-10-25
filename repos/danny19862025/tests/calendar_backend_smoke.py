#!/usr/bin/env python3
"""Test event creation in a disposable local EDS calendar, then remove it."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import uuid

import gi
gi.require_version('ECal', '2.0')
gi.require_version('EDataServer', '1.2')
from gi.repository import ECal, EDataServer

project = Path(__file__).resolve().parents[1]
helper = project / 'native/calendar.py'
registry = EDataServer.SourceRegistry.new_sync(None)
source_id = 'spotlight-test-' + str(uuid.uuid4())
source = EDataServer.Source.new_with_uid(source_id, None)
source.set_display_name('Spotlight disposable calendar test')
source.set_parent('local-stub')
source.set_enabled(True)
source.get_extension(EDataServer.SOURCE_EXTENSION_CALENDAR).set_backend_name('local')
registry.commit_source_sync(source, None)
created = None
client = None


def call(request, check=True):
    result = subprocess.run([sys.executable, str(helper)], input=json.dumps(request),
                            text=True, capture_output=True, timeout=15, check=check)
    return json.loads(result.stdout) if result.returncode == 0 else result


try:
    calendars = call({'operation': 'calendars'})
    assert any(c['id'] == source_id for c in calendars)
    uid = str(uuid.uuid4()) + '@spotlight.local'
    ical = ('BEGIN:VEVENT\r\nUID:' + uid + '\r\nDTSTAMP:20261017T000000Z\r\n'
            'SUMMARY:Spotlight fixture café 🎉\r\nDTSTART;VALUE=DATE:20270713\r\n'
            'DTEND;VALUE=DATE:20270714\r\nEND:VEVENT\r\n')
    created = call({'operation': 'create', 'calendar': source_id, 'ical': ical})['uid']
    client = ECal.Client.connect_sync(source, ECal.ClientSourceType.EVENTS, 5, None)
    ok, event = client.get_object_sync(created, None, None)
    assert ok and event.get_summary() == 'Spotlight fixture café 🎉'
    assert event.get_dtstart().is_date()
    assert (event.get_dtstart().get_year(), event.get_dtstart().get_month(), event.get_dtstart().get_day()) == (2027, 7, 13)
    rows = call({'operation': 'search', 'calendar': source_id, 'query': 'Spotlight fixture'})
    assert len(rows) == 1 and '20270713' in rows[0]['payload']
    bad = call({'operation': 'create', 'calendar': 'spotlight-nonexistent-test-calendar', 'ical': ical}, check=False)
    assert bad.returncode != 0
    print('Native calendar integration passed: calendar discovery, event creation, read-back, search, and unavailable-calendar errors.')
finally:
    if created:
        client = client or ECal.Client.connect_sync(source, ECal.ClientSourceType.EVENTS, 5, None)
        client.remove_object_sync(created, None, ECal.ObjModType.ALL, ECal.OperationFlags.NONE, None)
    # This source and its data belong only to this run.
    live = EDataServer.SourceRegistry.new_sync(None).ref_source(source_id)
    if live:
        live.remove_sync(None)
    folder = Path.home() / '.local/share/evolution/calendar' / source_id
    if folder.is_dir():
        shutil.rmtree(folder)
    print('Disposable calendar and test event removed.')
