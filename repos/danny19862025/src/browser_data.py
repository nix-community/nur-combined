"""Read browser databases through SQLite's read-only URI mode (including WAL).

Private temporary snapshots include live WAL data; profile files are never modified. Missing/busy profiles are reported without
preventing results from other profiles.
"""
from contextlib import contextmanager
import shutil
import tempfile
import json
import os
from pathlib import Path
import sqlite3
import sys


def profiles(home, config):
    firefox = [home / '.mozilla/firefox', config / 'mozilla/firefox',
               home / 'snap/firefox/common/.mozilla/firefox',
               home / '.var/app/org.mozilla.firefox/.mozilla/firefox']
    for root in firefox:
        if root.is_dir():
            for db in sorted(root.glob('*/places.sqlite')):
                yield 'Firefox', db.parent, 'firefox'
    for name, folder in [('Chrome', 'google-chrome'), ('Chrome Beta', 'google-chrome-beta'),
                         ('Chromium', 'chromium'), ('Brave', 'BraveSoftware/Brave-Browser')]:
        roots = [config / folder]
        if name == 'Chrome':
            roots.append(home / '.var/app/com.google.Chrome/config/google-chrome')
        if name == 'Chromium':
            roots.extend([home / 'snap/chromium/common/chromium',
                          home / '.var/app/org.chromium.Chromium/config/chromium'])
        for root in roots:
            if root.is_dir():
                for profile in sorted(root.iterdir()):
                    if profile.is_dir() and (profile.name == 'Default' or profile.name.startswith('Profile ')):
                        yield name, profile, 'chrome'


@contextmanager
def snapshot(path, scratch=None):
    # Opening a live WAL read-only can still update the shared-memory read marks.
    # Copy a stable main/WAL pair, then let SQLite read only the private snapshot.
    wal = Path(str(path) + '-wal')
    def version(file):
        try:
            st = file.stat()
            return st.st_ino, st.st_size, st.st_mtime_ns
        except FileNotFoundError:
            return None
    with tempfile.TemporaryDirectory(prefix='spotlight-browser-', dir=scratch) as temp:
        target = Path(temp) / 'profile.sqlite'
        for attempt in range(3):
            before = (version(path), version(wal))
            if sum(v[1] for v in before if v) > 512 * 1024 * 1024:
                raise ValueError('Profile history exceeds 512 MiB')
            try:
                shutil.copyfile(path, target)
                copied_wal = Path(str(target) + '-wal')
                if before[1]:
                    shutil.copyfile(wal, copied_wal)
                else:
                    copied_wal.unlink(missing_ok=True)
            except FileNotFoundError:
                continue
            if before == (version(path), version(wal)):
                db = sqlite3.connect(target.as_uri() + '?mode=ro', uri=True, timeout=0.1)
                try:
                    db.execute('PRAGMA query_only=ON')
                    yield db
                finally:
                    db.close()
                return
        raise ValueError('Browser history changed while reading; try again')


def read(mode, query, home=None, config=None, only='', scratch=None):
    home = Path(home or Path.home())
    config = Path(config or os.environ.get('XDG_CONFIG_HOME', home / '.config'))
    rows, errors = [], []
    query = query.casefold()
    def add(title, url, browser, stamp=0):
        if not isinstance(url, str) or not url.startswith(('https://', 'http://')):
            return
        title = title if isinstance(title, str) else url
        if query in (title + ' ' + url).casefold():
            rows.append(dict(title=title or url, url=url, browser=browser, stamp=stamp or 0))
    def walk(node, browser):
        if not isinstance(node, dict):
            return
        if node.get('type') == 'url':
            add(node.get('name'), node.get('url'), browser)
        for child in node.get('children', []):
            walk(child, browser)
    for browser, folder, kind in profiles(home, config):
        if only and only not in browser.casefold():
            continue
        try:
            if kind == 'chrome' and mode == 'bookmark':
                path = folder / 'Bookmarks'
                if path.is_file():
                    if path.stat().st_size > 32 * 1024 * 1024:
                        raise ValueError('Bookmarks file too large')
                    for node in json.loads(path.read_text()).get('roots', {}).values():
                        walk(node, browser)
                continue
            path = folder / ('places.sqlite' if kind == 'firefox' else 'History')
            if not path.is_file():
                continue
            with snapshot(path, scratch) as db:
                db.create_function('casefold', 1, lambda s: (s or '').casefold(), deterministic=True)
                if mode == 'bookmark':
                    sql = '''SELECT COALESCE(b.title,p.title) AS title,p.url,0 FROM moz_bookmarks b
                             JOIN moz_places p ON p.id=b.fk WHERE b.type=1'''
                elif kind == 'firefox':
                    sql = 'SELECT title,url,COALESCE(last_visit_date,0) FROM moz_places WHERE last_visit_date IS NOT NULL'
                else:
                    sql = 'SELECT title,url,(last_visit_time-11644473600000000) FROM urls WHERE last_visit_time>0'
                # Filter before the limit, with literal substring matching and bound arguments.
                sql = 'SELECT * FROM (' + sql + ') WHERE instr(casefold(COALESCE(title,\'\') || \' \' || url),casefold(?))>0 ORDER BY 3 DESC LIMIT 100'
                for title, url, stamp in db.execute(sql, (query,)):
                    add(title, url, browser, stamp)
        except (sqlite3.Error, OSError, ValueError, TypeError) as error:
            errors.append(browser + ': ' + str(error))
    rows.sort(key=lambda r: (-r['stamp'], r['title'].casefold()))
    seen = set()
    unique = []
    for row in rows:
        if row['url'] not in seen:
            seen.add(row['url'])
            unique.append(row)
    return dict(rows=unique[:80], errors=errors)


if __name__ == '__main__':
    print(json.dumps(read(*sys.argv[1:]), ensure_ascii=False))
