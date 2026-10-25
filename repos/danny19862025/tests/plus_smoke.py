#!/usr/bin/env python3
"""Isolated manifests, clipboard DB, dictionary and a real KWin window fixture.

XWayland permits synthetic clipboard writes without a physical input serial.
Use --wayland to check native Wayland UI/KWin without changing the clipboard.
"""
import json, os, sqlite3, struct, subprocess, sys, tempfile, time, zlib
from pathlib import Path

def png():
    def chunk(name,data):
        return struct.pack('!I',len(data))+name+data+struct.pack('!I',zlib.crc32(name+data))
    raw=(b'\0'+bytes((235,120,80))*96)*64
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('!IIBBBBB',96,64,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b'')

project=Path(__file__).resolve().parents[1]
wayland='--wayland' in sys.argv
arguments=[a for a in sys.argv[1:] if a!='--wayland']
binary=Path(arguments[0]).resolve() if arguments else project/'target/release/spotlight'
with tempfile.TemporaryDirectory(prefix='spotlight-plus-') as temp:
    root=Path(temp); home=root/'home'; data=root/'data'; scripts=data/'spotlight/scripts'
    home.mkdir(); scripts.mkdir(parents=True)
    for extension,mode in [('live','search'),('args','command'),('invalid','search')]:
        folder=scripts/extension; folder.mkdir()
        manifest={'schema_version':1,'id':extension,'name':'Argument Echo' if extension=='args' else extension.title(),'description':'Isolated extension fixture','mode':mode,'icon':'icon.png','command':['/usr/bin/python3','main.py'],'timeout_ms':5000}
        if mode=='command': manifest['args']=[{'name':'message','required':True,'placeholder':'Literal text'}]
        (folder/'manifest.json').write_text(json.dumps(manifest));(folder/'icon.png').write_bytes(png())
        (folder/'main.py').write_text('''import json,os,pathlib,sys,time
def emit(value): print(json.dumps(value),flush=True)
query=sys.argv[1] if len(sys.argv)>1 else ''
if pathlib.Path(__file__).parent.name=='invalid':
    print('not JSON',flush=True);sys.exit()
if pathlib.Path(__file__).parent.name=='args':
    pathlib.Path(os.environ['SPOTLIGHT_PLUS_ROOT'],'args.json').write_text(json.dumps(sys.argv[1:]))
    emit({'type':'result','id':'arg','title':query,'action':{'type':'copy','text':query}})
else:
    emit({'type':'result','id':'first','title':'First '+query,'action':{'type':'copy','text':query}})
    time.sleep(1.2 if query!='cancel' else 2.5)
    if query=='cancel': pathlib.Path(os.environ['SPOTLIGHT_PLUS_ROOT'],'uncancelled').write_text('bad')
    emit({'type':'result','id':'second','title':'Second '+query,'action':{'type':'copy','text':'second'}})
''')
    (scripts/'broken.json').write_text('{"schema_version":999}')
    dictionaries=data/'spotlight/dictionaries';dictionaries.mkdir()
    (dictionaries/'eng-spa.index').write_text('hello\tA\tF\n');(dictionaries/'eng-spa.dict').write_text('hola\n')
    klipper=data/'klipper';klipper.mkdir();db=klipper/'history3.sqlite'
    connection=sqlite3.connect(db)
    connection.executescript('CREATE TABLE main(uuid TEXT PRIMARY KEY,added_time REAL,last_used_time REAL,mimetypes TEXT,text TEXT);CREATE TABLE aux(uuid TEXT,mimetype TEXT,data_uuid TEXT);CREATE TABLE version(db_version INTEGER);INSERT INTO version VALUES(3);')
    uuid='a'*40;image_id='b'*40
    connection.execute('INSERT INTO main VALUES(?,?,?,?,?)',(uuid,1,2,'image/png',None));connection.execute('INSERT INTO aux VALUES(?,?,?)',(uuid,'image/png',image_id));connection.commit();connection.close()
    (klipper/'data'/uuid).mkdir(parents=True);(klipper/'data'/uuid/image_id).write_bytes(png())
    title=f'Spotlight Window Fixture {os.getpid()}'
    fixture_code='''import gi,sys
gi.require_version('Gtk','4.0')
from gi.repository import Gtk
app=Gtk.Application(application_id='local.spotlight.WindowFixture')
def activate(app):
    window=Gtk.ApplicationWindow(application=app,title=sys.argv[1]);window.set_default_size(300,180);window.present()
app.connect('activate',activate);app.run([])
'''
    fixture=subprocess.Popen(['/usr/bin/python3','-c',fixture_code,title],stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
    env=dict(os.environ,HOME=str(home),XDG_DATA_HOME=str(data),XDG_CONFIG_HOME=str(root/'config'),XDG_CACHE_HOME=str(root/'cache'),GSK_RENDERER='cairo',SPOTLIGHT_PLUS_ROOT=str(root),SPOTLIGHT_WINDOW_FIXTURE_TITLE=title,SPOTLIGHT_PLUS_FIXTURES='1')
    env.pop('KLIPPER_DATABASE',None)
    env['GDK_BACKEND']='wayland' if wayland else 'x11'
    if wayland: env['SPOTLIGHT_PLUS_SKIP_COPY']='1'
    try:
        subprocess.run([str(binary),'--smoke-test','--plus-smoke-test'],env=env,check=True,timeout=45)
        assert not (root/'uncancelled').exists()
        assert json.loads((root/'args.json').read_text())==['literal ; $(no shell)']
        print('Manifest streaming, literal args, cancellation, offline lookup, Klipper images, emoji memory, and live KWin switch verified. '+('Native Wayland: clipboard writes skipped (physical input serial required).' if wayland else 'XWayland: clipboard copying checked when original clipboard was empty, text, or an image.'))
    finally:
        fixture.terminate()
        try: fixture.communicate(timeout=3)
        except subprocess.TimeoutExpired: fixture.kill();fixture.communicate()
