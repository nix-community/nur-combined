#!/usr/bin/env python3
"""Private Docker/terminal/GitHub fixtures and a real local HTTP endpoint."""
import http.server
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import threading

project = Path(__file__).resolve().parents[1]
if '--inside' not in sys.argv:
    with tempfile.TemporaryDirectory(prefix='spotlight-kit-bus-') as directory:
        config = Path(directory)/'session.conf'
        config.write_text('<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd"><busconfig><type>session</type><listen>unix:tmpdir=/tmp</listen><auth>EXTERNAL</auth><policy context="default"><allow own="*"/><allow send_destination="*"/><allow receive_sender="*"/></policy></busconfig>')
        raise SystemExit(subprocess.call(['dbus-run-session', '--config-file='+str(config), '--', '/usr/bin/python3', str(Path(__file__).resolve()), '--inside']))

STUB = r'''#!/usr/bin/python3
import json,os,pathlib,sys,time
root=pathlib.Path(os.environ['SPOTLIGHT_KIT_ROOT'])
name=pathlib.Path(sys.argv[0]).name;args=sys.argv[1:]
if name=='git':
 if 'push' in args:
  with (root/'push-count').open('a') as f:f.write('push\n')
 else:os.execv(os.environ['SPOTLIGHT_REAL_GIT'],[os.environ['SPOTLIGHT_REAL_GIT']]+args)
elif name=='gh':
 assert args[0:2]==['repo','view'];assert args[-2:]==['--json','isPrivate']
 print(json.dumps({'isPrivate':not (root/'public-origin').exists()}))
elif name=='konsole':
 (root/'terminal-args.json').write_text(json.dumps(args))
elif name in ['docker','podman']:
 if args[0]=='ps':
  for row in [{'ID':'a'*64,'Names':'nginx','State':'running','Image':'nginx:fixture','Status':'Up'}, {'ID':'b'*64,'Names':'postgres','State':'exited','Image':'postgres:fixture','Status':'Exited'}]:print(json.dumps(row))
 elif args[0]=='logs':
  assert args[1:]==['--tail','200','--follow','--timestamps','a'*64]
  (root/'tail-pid').write_text(str(os.getpid()))
  print('nginx fixture ready',flush=True);print('stderr fixture',file=sys.stderr,flush=True)
  while True:time.sleep(.1)
 else:raise RuntimeError(args)
else:raise RuntimeError(name)
'''
class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({'login': 'spotlight-fixture', 'message': 'inline response'}).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def log_message(self, *_):
        pass

with tempfile.TemporaryDirectory(prefix='spotlight-devkit-') as directory:
    root = Path(directory)
    tools = root/'bin'
    tools.mkdir()
    for name in ['docker','podman','konsole','git','gh']:
        script = tools/name
        script.write_text(STUB)
        script.chmod(0o755)
    home = root/'home'
    home.mkdir()
    server = http.server.ThreadingHTTPServer(('127.0.0.1',0),Handler)
    threading.Thread(target=server.serve_forever,daemon=True).start()
    env = dict(os.environ,SPOTLIGHT_KIT_ROOT=str(root),SPOTLIGHT_REAL_GIT=shutil.which('git'),SPOTLIGHT_KIT_URL=f'http://127.0.0.1:{server.server_port}/user',HOME=str(home),RUSTUP_HOME=os.environ.get('RUSTUP_HOME',str(Path.home()/'.rustup')),CARGO_HOME=os.environ.get('CARGO_HOME',str(Path.home()/'.cargo')),XDG_DATA_HOME=str(root/'data'),XDG_CONFIG_HOME=str(root/'config'),XDG_CACHE_HOME=str(root/'cache'),PATH=str(tools)+os.pathsep+os.environ['PATH'],GSK_RENDERER='cairo',GTK_A11Y='none',GIO_USE_VFS='local',GSETTINGS_BACKEND='memory')
    try:
        for name in ['devkit::tests::fixture_backends','devkit_ui::tests::native_ui']:
            subprocess.run(['cargo','test','--offline',name,'--','--ignored','--exact','--test-threads=1','--nocapture'],cwd=project,env=env,check=True,timeout=60)
        assert (root/'push-count').read_text().splitlines()==['push']
        print('Container discovery, exact exec arguments, live tail cancellation/reaping, private-repo verification, staged-file preservation, HTTP response UI and Settings controls passed with private fixtures.')
    finally:
        server.shutdown()
