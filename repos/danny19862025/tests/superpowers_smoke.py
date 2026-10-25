#!/usr/bin/env python3
"""Real Rust WASM plugins, streaming/cancellation fixtures, temporary KWin desktop.

Requires a release build, the Rust wasm32-unknown-unknown target, the built
text-tools example, KDE Plasma, and Python GObject introspection.
The original virtual desktop is restored and the temporary one removed.
"""
import json, os, shutil, subprocess, sys, tempfile, time
from pathlib import Path
from gi.repository import Gio, GLib

project = Path(__file__).resolve().parents[1]
binary = Path(sys.argv[1]).resolve() if len(sys.argv)>1 else project/'target/release/spotlight'
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
manager='org.kde.KWin.VirtualDesktopManager'
def call(interface, method, args):
    return bus.call_sync('org.kde.KWin','/VirtualDesktopManager',interface,method,args,None,Gio.DBusCallFlags.NONE,2000,None).unpack()
def properties():
    return call('org.freedesktop.DBus.Properties','GetAll',GLib.Variant('(s)',(manager,)))[0]
def restore(desktop):
    call('org.freedesktop.DBus.Properties','Set',GLib.Variant('(ssv)',(manager,'current',GLib.Variant('s',desktop))))

with tempfile.TemporaryDirectory(prefix='spotlight-superpowers-') as temp:
    root=Path(temp); home=root/'home';data=root/'data';bin_dir=root/'bin'
    (home/'Notes').mkdir(parents=True);bin_dir.mkdir()
    note=home/'Notes/stream.md';note.write_text('stream-fixture is ready\n')
    real_rg=shutil.which('rg');assert real_rg
    rg=bin_dir/'rg'
    rg.write_text('''#!/usr/bin/python3
import json,os,pathlib,sys,time
root=pathlib.Path(os.environ['SPOTLIGHT_SUPER_ROOT'])
if 'stream-fixture' in sys.argv:
    print(json.dumps({'type':'match','data':{'path':{'text':os.environ['SPOTLIGHT_STREAM_NOTE']},'line_number':1,'lines':{'text':'stream-fixture is ready\\n'}}}),flush=True)
    time.sleep(3)
    (root/'search-uncancelled').write_text('bad')
else:
    os.execv(os.environ['SPOTLIGHT_REAL_RG'],[os.environ['SPOTLIGHT_REAL_RG']]+sys.argv[1:])
''');rg.chmod(0o755)
    plugins=data/'spotlight/plugins';plugins.mkdir(parents=True)
    folder=plugins/'text-tools';folder.mkdir()
    for name in ('manifest.json','plugin.wasm'):
        shutil.copyfile(project/'examples/plugins/text-tools'/name,folder/name)
    loop=plugins/'loop';loop.mkdir()
    subprocess.run(['rustc','--edition=2024','--target','wasm32-unknown-unknown','--crate-type','cdylib','-C','panic=abort','-O',str(project/'tests/fixtures/wasm_loop.rs'),'-o',str(loop/'plugin.wasm')],check=True)
    (loop/'manifest.json').write_text(json.dumps({'schema_version':1,'id':'wasm-loop','name':'WASM cancellation fixture','runtime':'wasm','module':'plugin.wasm','mode':'search','timeout_ms':5000}))
    before=properties();original=before['current'];initial_ids={d[1] for d in before['desktops']}
    name=f'Spotlight Test Desktop {os.getpid()}';fixture_id=None
    try:
        call(manager,'createDesktop',GLib.Variant('(us)',(before['count'],name)))
        for _ in range(30):
            after=properties()
            candidates=[d[1] for d in after['desktops'] if d[1] not in initial_ids and d[2]==name]
            if candidates: fixture_id=candidates[0];break
            time.sleep(0.05)
        assert fixture_id,'KWin did not create its temporary test desktop'
        env=dict(os.environ,HOME=str(home),XDG_DATA_HOME=str(data),XDG_CONFIG_HOME=str(root/'config'),XDG_CACHE_HOME=str(root/'cache'),GSK_RENDERER='cairo',GDK_BACKEND='wayland',SPOTLIGHT_SUPER_FIXTURES='1',SPOTLIGHT_SUPER_ROOT=str(root),SPOTLIGHT_STREAM_NOTE=str(note),SPOTLIGHT_REAL_RG=real_rg,SPOTLIGHT_DESKTOP_FIXTURE_NAME=name,SPOTLIGHT_DESKTOP_FIXTURE_ID=fixture_id,SPOTLIGHT_DESKTOP_ORIGINAL_ID=original,PATH=str(bin_dir)+os.pathsep+os.environ['PATH'])
        subprocess.run([str(binary),'--smoke-test','--superpowers-smoke-test'],env=env,check=True,timeout=45)
        assert properties()['current']==original
        assert not (root/'search-uncancelled').exists()
        time.sleep(0.1)
        processes=subprocess.check_output(['ps','-eo','args='],text=True)
        assert not any('--wasm-plugin-worker' in line and str(plugins) in line for line in processes.splitlines()),'Cancelled WASM worker was not reaped'
        print('Native Wayland, Rust WASM execution, bounded loop handling, worker cleanup, streamed rg cancellation, and reversible virtual desktop switching verified.')
    finally:
        restore(original)
        if fixture_id:
            call(manager,'removeDesktop',GLib.Variant('(s)',(fixture_id,)))
        else:
            for desktop in properties()['desktops']:
                if desktop[1] not in initial_ids and desktop[2]==name:
                    call(manager,'removeDesktop',GLib.Variant('(s)',(desktop[1],)))
