#!/usr/bin/env python3
"""Verify live KWin controls against three throwaway GTK processes only."""
import os
from pathlib import Path
import subprocess
import tempfile
import time
import uuid

project=Path(__file__).resolve().parents[1]
code='''import gi,sys
from pathlib import Path
gi.require_version('Gtk','4.0')
from gi.repository import Gtk,GLib
app=Gtk.Application(application_id='local.spotlight.ControlFixture.'+sys.argv[3])
def activate(app):
    for n in range(int(sys.argv[4])):
        w=Gtk.ApplicationWindow(application=app,title=sys.argv[1]+' '+str(n+1));w.set_default_size(320,120);w.set_child(Gtk.Label(label='Disposable Spotlight test window'));w.present()
    def ready():Path(sys.argv[2]).write_text('ready');return False
    GLib.timeout_add(350,ready)
app.connect('activate',activate);app.run([])
'''
with tempfile.TemporaryDirectory(prefix='spotlight-window-controls-') as directory:
    root=Path(directory);tag='Spotlight Control Fixture '+uuid.uuid4().hex[:10];children=[]
    try:
        for mode,count in [('close',1),('quit',2),('kill',1)]:
            child=subprocess.Popen(['/usr/bin/python3','-c',code,f'{tag} {mode}',str(root/mode),mode+uuid.uuid4().hex[:10],str(count)],stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
            children.append(child)
        deadline=time.monotonic()+10
        while not all((root/mode).exists() for mode in ['close','quit','kill']):
            if time.monotonic()>deadline:raise RuntimeError('Fixture windows did not open')
            time.sleep(.1)
        env=dict(os.environ,SPOTLIGHT_WINDOW_CONTROLS_ROOT=str(root),SPOTLIGHT_WINDOW_CONTROLS_TAG=tag,SPOTLIGHT_WINDOW_CONTROLS_KILL_PID=str(children[2].pid),XDG_DATA_HOME=str(root/'data'),XDG_CONFIG_HOME=str(root/'config'),XDG_CACHE_HOME=str(root/'cache'))
        result=subprocess.run(['cargo','test','--offline','features_smoke::kwin_window_controls','--','--ignored','--exact','--test-threads=1','--nocapture'],cwd=project,env=env,capture_output=True,text=True,timeout=40)
        print(result.stdout,end='')
        if result.returncode:print(result.stderr);result.check_returncode()
        for child in children:child.wait(timeout=8)
        assert children[0].returncode==0 and children[1].returncode==0
        assert children[2].returncode==-9
        print('Only the three disposable fixture processes were closed; no existing application was targeted.')
    finally:
        for child in children:
            if child.poll() is None:child.terminate()
            try:child.communicate(timeout=3)
            except subprocess.TimeoutExpired:child.kill();child.communicate()
