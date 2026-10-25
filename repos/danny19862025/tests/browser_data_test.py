#!/usr/bin/env python3
"""Temporary browser profiles, including a live WAL and literal search strings."""
import json
from pathlib import Path
import runpy
import sqlite3
import tempfile
import unittest

read = runpy.run_path(str(Path(__file__).resolve().parents[1] / 'src/browser_data.py'))['read']


class BrowserTest(unittest.TestCase):
    def test_profiles_bookmarks_filters_and_live_wal(self):
        with tempfile.TemporaryDirectory(prefix='spotlight-browser-') as tmp:
            home = Path(tmp)
            config = home / '.config'
            ff = home / '.mozilla/firefox/demo.default'
            ff.mkdir(parents=True)
            chrome = config / 'google-chrome/Default'
            chrome.mkdir(parents=True)
            db = sqlite3.connect(ff / 'places.sqlite')
            db.execute('PRAGMA journal_mode=WAL')
            db.executescript('''CREATE TABLE moz_places(id INTEGER PRIMARY KEY,title TEXT,url TEXT,last_visit_date INTEGER);
                CREATE TABLE moz_bookmarks(title TEXT,fk INTEGER,type INTEGER);''')
            db.executemany('INSERT INTO moz_places VALUES(?,?,?,?)', [
                (1, 'YouTube café', 'https://youtube.com/watch?v=fixture', 100),
                (2, 'GitHub', 'https://github.com/example', 200),
                (3, 'Unsafe', 'javascript:alert(1)', 300),
                (4, "literal 100%_ 'quote'", 'https://example.test/literal', 400),
                (5, 'CAFÉ', 'https://example.test/cafe', 500),
            ] + [(n, 'Recent', f'https://example.test/{n}', n * 1000) for n in range(6, 150)])
            db.execute("INSERT INTO moz_bookmarks VALUES('Firefox GitHub',2,1)")
            db.commit()
            ch = sqlite3.connect(chrome / 'History')
            ch.execute('CREATE TABLE urls(title TEXT,url TEXT,last_visit_time INTEGER)')
            ch.execute('INSERT INTO urls VALUES(?,?,?)', ('Chrome YouTube', 'https://youtube.com/chrome', 11644473600000600))
            ch.commit()
            ch.close()
            (chrome / 'Bookmarks').write_text(json.dumps({'roots': {'bookmark_bar': {'children': [
                {'type': 'folder', 'children': [{'type': 'url', 'name': 'Chrome GitHub', 'url': 'https://github.com/chrome'}]},
                {'type': 'url', 'name': 'ignore', 'url': 'file:///private'},
            ]}}}))
            before = {p: p.read_bytes() for p in home.rglob('*') if p.is_file()}
            result = read('history', 'youtube', home, config)
            self.assertFalse(result['errors'])
            self.assertEqual(len(result['rows']), 2)
            self.assertEqual(result['rows'][0]['browser'], 'Chrome')
            self.assertEqual(len(read('bookmark', 'github', home, config)['rows']), 2)
            self.assertEqual(len(read('history', "100%_ 'quote'", home, config)['rows']), 1)
            self.assertEqual(len(read('history', 'café', home, config)['rows']), 2)
            self.assertEqual(len(read('history', 'youtube', home, config, 'chrom')['rows']), 1)
            self.assertEqual(read('history', 'javascript', home, config)['rows'], [])
            after = {p: p.read_bytes() for p in home.rglob('*') if p.is_file()}
            self.assertEqual(before, after, 'Reading must not modify databases or sidecars')
            db.close()

    def test_chrome_live_wal_multiple_profiles_without_debugging(self):
        with tempfile.TemporaryDirectory() as tmp:
            home=Path(tmp);config=home/'.config';connections=[]
            for profile,stamp in [('Default',100),('Profile 1',200)]:
                directory=config/'google-chrome'/profile;directory.mkdir(parents=True)
                db=sqlite3.connect(directory/'History');connections.append(db)
                db.execute('PRAGMA journal_mode=WAL')
                db.execute('CREATE TABLE urls(title TEXT,url TEXT,last_visit_time INTEGER)')
                db.commit()
                db.execute('INSERT INTO urls VALUES(?,?,?)',('Live café '+profile,'https://example.test/'+profile.replace(' ','-'),11644473600000000+stamp));db.commit()
            try:
                before={p:p.read_bytes() for p in home.rglob('*') if p.is_file()}
                result=read('history','CAFÉ',home,config)
                self.assertFalse(result['errors'])
                self.assertEqual([r['url'] for r in result['rows']],['https://example.test/Profile-1','https://example.test/Default'])
                self.assertEqual(before,{p:p.read_bytes() for p in home.rglob('*') if p.is_file()})
            finally:
                for db in connections:db.close()

    def test_one_broken_profile_does_not_hide_others(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            profile = home / '.config/chromium/Profile 1'
            profile.mkdir(parents=True)
            (profile / 'History').write_bytes(b'not a database')
            result = read('history', '', home, home / '.config')
            good=home/'.config/google-chrome/Profile 2';good.mkdir(parents=True)
            db=sqlite3.connect(good/'History');db.execute('CREATE TABLE urls(title TEXT,url TEXT,last_visit_time INTEGER)')
            db.execute('INSERT INTO urls VALUES(?,?,?)',('Available page','https://example.test/good',11644473600000100));db.commit();db.close()
            result=read('history','',home,home/'.config')
            self.assertEqual([r['url'] for r in result['rows']],['https://example.test/good'])
            self.assertTrue(result['errors'])


if __name__ == '__main__':
    unittest.main()
