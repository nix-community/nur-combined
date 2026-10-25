#!/usr/bin/env python3
"""Check folder routing with a terminal MIME default and a private D-Bus."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

project = Path(__file__).resolve().parents[1]
if '--inside' not in sys.argv:
    with tempfile.TemporaryDirectory(prefix='spotlight-folder-bus-') as directory:
        configuration = Path(directory) / 'session.conf'
        configuration.write_text('<busconfig><type>session</type><listen>unix:tmpdir=/tmp</listen>'
                                 '<policy context="default"><allow own="*"/><allow send_destination="*"/>'
                                 '<allow receive_sender="*"/></policy></busconfig>')
        for mode in ('service', 'fallback'):
            result = subprocess.run(['dbus-run-session', '--config-file=' + str(configuration), '--',
                                     sys.executable, __file__, '--inside', mode], capture_output=True,
                                    text=True, timeout=20)
            if result.returncode:
                print(result.stdout + result.stderr, file=sys.stderr)
                result.check_returncode()
            print(result.stdout, end='')
    print('Folder routing verified through FileManager1 and file-manager fallback; no terminal was launched.')
    sys.exit(0)

import gi
gi.require_version('Gio', '2.0')
from gi.repository import Gio, GLib

mode = sys.argv[-1]
with tempfile.TemporaryDirectory(prefix='spotlight-folder-open-') as directory:
    root = Path(directory)
    home, data, config = root / 'home', root / 'data', root / 'config'
    apps = data / 'applications'
    for folder in (home, apps, config, root / 'empty-system-data'):
        folder.mkdir(parents=True, exist_ok=True)
    for resource in ('glib-2.0', 'icons', 'mime'):
        if (Path('/usr/share') / resource).exists():
            (root / 'empty-system-data' / resource).symlink_to(Path('/usr/share') / resource)
    folder = home / 'Folder café # & test'
    folder.mkdir()
    document = home / 'ordinary document.txt'
    document.write_text('A plain-text file\n')
    (data / 'recently-used.xbel').write_text(
        '<?xml version="1.0"?><xbel version="1.0" xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info">'
        f'<bookmark href="{folder.as_uri()}" added="2026-10-17T00:00:00Z" modified="2026-10-17T00:00:00Z" visited="2026-10-17T00:00:00Z">'
        '<info><metadata owner="http://freedesktop.org"><mime:mime-type type="inode/directory"/>'
        '</metadata></info></bookmark></xbel>')
    log = root / 'opened.jsonl'
    helper = root / 'record-open.py'
    helper.write_text('import json, os, sys\nfrom pathlib import Path\nwith Path(os.environ["SPOTLIGHT_OPEN_LOG"]).open("a") as f:\n    f.write(json.dumps(sys.argv[1:]) + "\\n")\n')
    for kind, mime, categories in (
        ('terminal', 'inode/directory;', 'System;TerminalEmulator;'),
        ('manager', 'inode/directory;', 'Utility;FileManager;'),
        ('document', 'text/plain;application/octet-stream;', 'Utility;')):
        (apps / f'fixture-{kind}.desktop').write_text(
            f'[Desktop Entry]\nType=Application\nName=Fixture {kind}\nExec=/usr/bin/python3 "{helper}" {kind} %u\n'
            f'Terminal=false\nNoDisplay=true\nMimeType={mime}\nCategories={categories}\n')
    (config / 'mimeapps.list').write_text(
        '[Default Applications]\ninode/directory=fixture-terminal.desktop\ntext/plain=fixture-document.desktop\napplication/octet-stream=fixture-document.desktop\n'
        '[Added Associations]\ninode/directory=fixture-terminal.desktop;fixture-manager.desktop;\n')
    env = dict(os.environ, HOME=str(home), XDG_DATA_HOME=str(data), XDG_CONFIG_HOME=str(config),
               XDG_CACHE_HOME=str(root / 'cache'), XDG_DATA_DIRS=str(root / 'empty-system-data'),
               GSK_RENDERER='cairo', SPOTLIGHT_OPEN_LOG=str(log), NO_AT_BRIDGE='1',
               GTK_A11Y='none', GIO_USE_VFS='local', GSETTINGS_BACKEND='memory')
    interface = Gio.DBusNodeInfo.new_for_xml('''<node><interface name="org.freedesktop.FileManager1">
      <method name="ShowFolders"><arg type="as" direction="in"/><arg type="s" direction="in"/></method>
    </interface></node>''').interfaces[0]
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    requests = []

    def show_folders(connection, sender, path, iface, method, parameters, invocation):
        uris, startup = parameters.unpack()
        requests.extend(uris)
        if mode == 'fallback':
            invocation.return_dbus_error('org.freedesktop.DBus.Error.NotSupported', 'Fixture: no folder service')
        else:
            invocation.return_value(GLib.Variant('()', ()))

    bus.register_object('/org/freedesktop/FileManager1', interface, show_folders, None, None)
    reply = bus.call_sync('org.freedesktop.DBus', '/org/freedesktop/DBus', 'org.freedesktop.DBus',
                          'RequestName', GLib.Variant('(su)', ('org.freedesktop.FileManager1', 0)),
                          None, Gio.DBusCallFlags.NONE, 2000, None)
    assert reply.unpack()[0] == 1
    with (root / 'app.log').open('w+') as output:
        process = subprocess.Popen([str(project / 'target/release/spotlight'), '--smoke-test', '--folder-open-smoke-test'],
                                   env=env, stdout=output, stderr=output)
        loop = GLib.MainLoop()
        timed_out = False

        def poll():
            if process.poll() is None:
                return True
            loop.quit()
            return False

        def deadline():
            global timed_out
            timed_out = True
            process.kill()
            loop.quit()
            return False

        GLib.timeout_add(100, poll)
        GLib.timeout_add_seconds(12, deadline)
        loop.run()
        process.wait(timeout=3)
        output.seek(0)
        assert not timed_out and process.returncode == 0, output.read()
    # Desktop launches are asynchronous; wait briefly for the fixture helper to finish.
    import time
    limit = time.monotonic() + 3
    while time.monotonic() < limit:
        records = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
        if len(records) >= (4 if mode == 'fallback' else 1):
            break
        time.sleep(0.05)
    assert len(requests) == 3, requests
    requested_paths = [Gio.File.new_for_uri(uri).get_path() for uri in requests]
    assert requested_paths[:2] == [str(folder), str(folder)], requests
    assert requested_paths[2] == str(data / 'spotlight/scripts'), requests
    assert all(uri.startswith('file:') and ' ' not in uri and '#' not in uri for uri in requests)
    assert not any(record[0] == 'terminal' for record in records), records
    documents = [record for record in records if record[0] == 'document']
    assert len(documents) == 1, records
    assert Gio.File.new_for_commandline_arg(documents[0][1]).get_path() == str(document)
    managers = [record for record in records if record[0] == 'manager']
    assert len(managers) == (3 if mode == 'fallback' else 0), records
    if managers:
        opened = [Gio.File.new_for_commandline_arg(record[1]).get_path() for record in managers]
        assert sorted(opened) == sorted(requested_paths), opened
    print(f'{mode}: folders opened in the file manager, documents used their default app, terminal launches = 0.')
