#!/usr/bin/env python3
"""Exercise local workflows with isolated data and one disposable KWin window."""
import json
import os
import signal
from pathlib import Path
import subprocess
import tempfile
import time
import uuid

FIXTURE = r'''
import gi,sys,json,subprocess
from pathlib import Path
gi.require_version('Gtk','4.0')
from gi.repository import Gtk,GLib,Gdk
root=Path(sys.argv[1]);app=Gtk.Application(application_id='local.spotlight.WorkflowFixture.f'+sys.argv[2])
original=[None,None]
def activate(app):
 w=Gtk.ApplicationWindow(application=app,title='Spotlight Workflow Fixture '+sys.argv[2]);w.set_default_size(360,220)
 view=Gtk.TextView();w.set_child(view);w.present();clip=w.get_clipboard()
 def text(c,r):
  try:original[1]=c.read_text_finish(r)
  except GLib.Error:pass
  (root/'ready').write_text('ready')
 def image(c,r):
  try:original[0]=c.read_texture_finish(r)
  except GLib.Error:pass
  clip.read_text_async(None,text)
 GLib.timeout_add(400,lambda: (clip.read_texture_async(None,image),False)[1])
 def poll():
  command=root/'command.json'
  if not command.exists():return True
  op=json.loads(command.read_text());command.unlink()
  if op['kind']=='stop':
   restore=root/'restore';restore.mkdir(exist_ok=True)
   mime='text/plain;charset=utf-8';data=(original[1] or '').encode()
   if original[0] is not None:mime='image/png';data=original[0].save_to_png_bytes().get_data()
   (restore/'0').write_bytes(data);(restore/'queue.json').write_text(json.dumps([mime]))
   subprocess.Popen([sys.argv[3],str(restore/'queue.json'),'--restore'],stdin=subprocess.DEVNULL,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
   GLib.timeout_add(800,lambda:app.quit());return False
  if op['kind']=='paste':
   view.get_buffer().set_text('');view.emit('paste-clipboard')
   attempts=[0]
   def finish():
    b=view.get_buffer();text=b.get_text(b.get_start_iter(),b.get_end_iter(),False);attempts[0]+=1
    if not text and attempts[0]<60:return True
    (root/op['result']).write_text(text);return False
   GLib.timeout_add(30,finish)
  if op['kind']=='image':
   def done(c,r):
    tex=c.read_texture_finish(r);(root/op['result']).write_text(str(tex.get_width())+'x'+str(tex.get_height()))
   clip.read_texture_async(None,done)
  if op['kind']=='copy':clip.set_content(Gdk.ContentProvider.new_for_value('External clipboard replacement'));(root/op['result']).write_text('copied')
  return True
 GLib.timeout_add(30,poll)
app.connect('activate',activate);app.run([])
'''
project = Path(__file__).resolve().parents[1]
subprocess.run(["sh", "native/build-pastequeue.sh"], cwd=project, check=True)
with tempfile.TemporaryDirectory(prefix='spotlight-workflows-') as directory:
    root = Path(directory)
    tag = uuid.uuid4().hex[:10]
    fixture = subprocess.Popen(['/usr/bin/python3', '-c', FIXTURE, str(root), tag, str(project/'target/native/spotlight-pastequeue')])
    try:
        deadline = time.monotonic() + 10
        while not (root/'ready').exists():
            if fixture.poll() is not None or time.monotonic() > deadline:
                raise RuntimeError('Fixture did not open')
            time.sleep(.05)
        env = dict(os.environ, SPOTLIGHT_WORKFLOW_ROOT=str(root), SPOTLIGHT_WORKFLOW_TAG=tag, SPOTLIGHT_PASTEQUEUE_HELPER=str(project/"target/native/spotlight-pastequeue"),
                   XDG_DATA_HOME=str(root/'data'), XDG_CONFIG_HOME=str(root/'config'),
                   XDG_CACHE_HOME=str(root/'cache'), GSK_RENDERER='cairo')
        test = subprocess.Popen(['cargo', 'test', '--offline', 'workflow_smoke::native_workflows', '--',
                        '--ignored', '--exact', '--test-threads=1', '--nocapture'],
                       cwd=project, env=env, start_new_session=True)
        try:
            if test.wait(timeout=60):raise RuntimeError("Desktop workflow test failed")
        finally:
            try:os.killpg(test.pid, signal.SIGTERM)
            except ProcessLookupError:pass
    finally:
        (root/'command.json').write_text(json.dumps({'kind': 'stop'}))
        try:
            fixture.wait(timeout=5)
        except subprocess.TimeoutExpired:
            fixture.terminate()
            fixture.wait(timeout=3)
