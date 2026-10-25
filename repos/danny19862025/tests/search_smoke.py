#!/usr/bin/env python3
"""Real GTK, ripgrep and image decoding against disposable local fixtures."""
import os
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import zlib
from xml.sax.saxutils import escape


def png(width, height):
    def chunk(name, data):
        return struct.pack('!I', len(data)) + name + data + struct.pack('!I', zlib.crc32(name + data))
    rows = b''.join(b'\0' + bytes((70, 160, 235)) * width for _ in range(height))
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('!IIBBBBB', width, height, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(rows)) + chunk(b'IEND', b''))


project = Path(__file__).resolve().parents[1]
binary = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else project / 'target/release/spotlight'
with tempfile.TemporaryDirectory(prefix='spotlight-search-') as temp:
    root = Path(temp)
    home, data, config = root / 'home', root / 'data', root / 'config'
    for directory in (home / 'Notes', home / 'Pictures', data / 'spotlight/contacts', data / 'spotlight/calendars', config):
        directory.mkdir(parents=True, exist_ok=True)
    note = home / 'Notes/story.md'
    note.write_text('Notes about development\nRust async makes the launcher responsive.\n')
    (home / 'Priority Fixture').write_text('App priority search fixture')
    (home / 'Search File Only.txt').write_text('Indexed file without recent history')
    (home / 'Priority Fixture Folder').mkdir()
    (home / 'Notes/.hidden.md').write_text('Rust secret fixture')
    (home / 'Notes/target').mkdir()
    (home / 'Notes/target/output.txt').write_text('Rust build output')
    image = home / 'Pictures/blue sample.png'
    image.write_bytes(png(120, 80))
    (data / 'spotlight/contacts/danny.vcf').write_text('BEGIN:VCARD\nVERSION:3.0\nFN:Danny Example\nEMAIL:danny@example.test\nTEL:+61 123\nEND:VCARD\n')
    (data / 'spotlight/calendars/work.ics').write_text('BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nUID:fixture\nSUMMARY:Rust meetup\nDTSTART;TZID=Australia/Sydney:20261020T180000\nRRULE:FREQ=WEEKLY\nLOCATION:Library\nEND:VEVENT\nEND:VCALENDAR\n')
    records = []
    hidden_config = home / '.config/editor/settings.json'
    hidden_config.parent.mkdir(parents=True)
    hidden_config.write_text('{}')
    for path, date in ((home / 'Notes/.hidden.md', '2026-10-18T00:00:00Z'),
                       (hidden_config, '2026-10-17T00:00:00Z'),
                       (image, '2026-10-16T00:00:00Z'), (note, '2026-10-15T00:00:00Z')):
        records.append(f'<bookmark href="{escape(path.as_uri(), {chr(34): "&quot;"})}" added="{date}" modified="{date}" visited="{date}"><info><metadata owner="http://freedesktop.org"><mime:mime-type type="text/plain"/></metadata></info></bookmark>')
    (data / 'recently-used.xbel').write_text('<?xml version="1.0"?><xbel version="1.0" xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info">' + ''.join(records) + '</xbel>')
    env = dict(os.environ, HOME=str(home), XDG_DATA_HOME=str(data), XDG_CONFIG_HOME=str(config),
               XDG_CACHE_HOME=str(root / 'cache'), GSK_RENDERER='cairo', SPOTLIGHT_SEARCH_FIXTURES='1')
    subprocess.run([str(binary), '--smoke-test', '--search-tools-smoke-test'], env=env, check=True, timeout=40)
    print('Isolated search, text tools, thumbnails, contact and calendar fixtures verified.')
