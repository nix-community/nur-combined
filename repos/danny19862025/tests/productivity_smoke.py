#!/usr/bin/python3
"""Private local-only AI, native settings, meeting, and WASM Store verification."""
import contextlib
import http.server
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import threading

project=Path(__file__).resolve().parents[1]
if '--inside' not in sys.argv:
    subprocess.run(['cargo','build','--release','--locked','--offline'],cwd=project,check=True)
    subprocess.run(['sh','native/build-freebusy.sh'],cwd=project,check=True)
    subprocess.run(['/usr/bin/python3','tests/freebusy_smoke.py'],cwd=project,check=True)
    with tempfile.TemporaryDirectory(prefix='spotlight-productivity-bus-') as directory:
        config=Path(directory)/'session.conf';config.write_text('''<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd"><busconfig><type>session</type><listen>unix:tmpdir=/tmp</listen><auth>EXTERNAL</auth><policy context="default"><allow own="*"/><allow send_destination="*"/><allow receive_sender="*"/></policy></busconfig>''')
        raise SystemExit(subprocess.call(['dbus-run-session','--config-file='+str(config),'--','/usr/bin/python3',__file__,'--inside'],cwd=project))

with tempfile.TemporaryDirectory(prefix='spotlight-productivity-') as directory:
    root=Path(directory);home=root/'home';tools=root/'bin';config=root/'config';data=root/'data'
    for path in [home,tools,config,data]:path.mkdir()
    helpers=home/'.local/lib/spotlight';helpers.mkdir(parents=True)
    shutil.copy2(project/'target/native/spotlight-freebusy',helpers/'spotlight-freebusy')
    bridge=helpers/'spotlight-pim';bridge.write_text('''#!/usr/bin/python3
import datetime,json,sys,time
assert sys.argv[1:]==['calendar-busy']
start=int((time.time()+7200+299)//300)*300
fmt=lambda t:datetime.datetime.fromtimestamp(t,datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
payload='BEGIN:VCALENDAR\\r\\nVERSION:2.0\\r\\nBEGIN:VEVENT\\r\\nUID:fixture\\r\\nDTSTART:'+fmt(start)+'\\r\\nDTEND:'+fmt(start+3600)+'\\r\\nEND:VEVENT\\r\\nEND:VCALENDAR\\r\\n'
print(json.dumps([{'payload':payload,'collection':'Fixture calendar'}]))
''');bridge.chmod(0o755)
    ollama=tools/'ollama';ollama.write_text('#!/bin/sh\necho "CLI must not receive clipboard data" >&2\nexit 1\n');ollama.chmod(0o755)
    docker=tools/'docker';docker.write_text('#!/usr/bin/python3\nimport os,pathlib\npathlib.Path(os.environ["SPOTLIGHT_PRODUCTIVITY_ROOT"],"docker-called").touch()\nprint("[]")\n');docker.chmod(0o755)
    requests=[]
    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self,*args):pass
        def send(self,status,value):
            body=json.dumps(value).encode();self.send_response(status);self.send_header('Content-Type','application/json');self.send_header('Content-Length',str(len(body)));self.end_headers();self.wfile.write(body)
        def do_GET(self):
            requests.append((self.path,None))
            if self.path=='/api/status':
                if (root/'old-server').exists():return self.send(404,{})
                if (root/'redirect-server').exists():
                    self.send_response(302);self.send_header('Location','https://example.invalid/private');self.end_headers();return
                return self.send(200,{'cloud':{'disabled':not (root/'cloud-enabled').exists()}})
            if self.path=='/api/tags':return self.send(200,{'models':[{'name':'remote:cloud','remote_host':'https://ollama.com'},{'name':'test-local:latest'}]})
            self.send(404,{})
        def do_POST(self):
            value=json.loads(self.rfile.read(int(self.headers['Content-Length'])))
            requests.append((self.path,value))
            if self.path=='/api/show':
                result={'model_info':{'general.architecture':'llama'},'details':{'format':'gguf'}}
                if (root/'remote-model').exists():result['remote_model']='remote';result['remote_host']='https://ollama.com'
                return self.send(200,result)
            if self.path=='/api/generate':
                assert not any((root/m).exists() for m in ['cloud-enabled','remote-model','old-server','redirect-server'])
                assert value['model']=='test-local:latest' and value['stream'] is False
                return self.send(200,{'done':True,'model':'test-local:latest','response':'Summary generated locally'})
            self.send(404,{})
    server=http.server.ThreadingHTTPServer(('127.0.0.1',0),Handler);thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
    build=subprocess.run(['cargo','test','--offline','--no-run','--message-format=json'],cwd=project,text=True,capture_output=True)
    if build.returncode:print(build.stderr[-4000:]);raise SystemExit(build.returncode)
    binaries=[v['executable'] for line in build.stdout.splitlines() if (v:=json.loads(line)).get('executable') and v.get('profile',{}).get('test')]
    env=dict(os.environ,HOME=str(home),XDG_CONFIG_HOME=str(config),XDG_DATA_HOME=str(data),XDG_CACHE_HOME=str(root/'cache'),SPOTLIGHT_PRODUCTIVITY_ROOT=str(root),SPOTLIGHT_OLLAMA_PORT=str(server.server_port),PATH=str(tools)+os.pathsep+os.environ['PATH'],GSK_RENDERER='cairo',GIO_USE_VFS='local',GTK_A11Y='none',NO_AT_BRIDGE='1',GSETTINGS_BACKEND='memory',HTTP_PROXY='http://127.0.0.1:1',http_proxy='http://127.0.0.1:1')
    try:
        for name in ['productivity_smoke::backends','productivity_smoke::native_ui']:
            with (root/'output.log').open('w+') as output:
                result=subprocess.run([binaries[0],name,'--ignored','--exact','--test-threads=1','--nocapture'],cwd=project,env=env,stdout=output,stderr=output,timeout=45);output.seek(0);report=output.read()
            if result.returncode:
                if os.environ.get('SPOTLIGHT_TEST_GDB') and result.returncode < 0 and shutil.which('gdb'):
                    with Path('/tmp/spotlight-productivity-gdb.log').open('w') as debug:
                        subprocess.run(['gdb','--batch','-ex','run','-ex','bt','--args',binaries[0],name,'--ignored','--exact','--test-threads=1','--nocapture'],cwd=project,env=env,stdout=debug,stderr=debug,timeout=45)
                Path('/tmp/spotlight-productivity-failure.log').write_text(report);print(report[:3000]+'\n'+report[-800:]);raise SystemExit(result.returncode)
            print(name+': PASS',flush=True)
        generated=[body for route,body in requests if route=='/api/generate']
        assert len(generated)==2 and {r['prompt'] for r in generated}=={'Private clipboard fixture','Private UI clipboard fixture'}
        assert not any(p.name.startswith('.store-') for p in (data/'spotlight/plugins').iterdir())
        worker=subprocess.run([str(project/'target/release/spotlight'),'--wasm-plugin-worker',str(data/'spotlight/plugins/wasm-text/plugin.wasm')],input=json.dumps({'api_version':1,'query':'hello','args':['hello']}),text=True,capture_output=True,env={},check=True,timeout=8)
        output=[json.loads(line) for line in worker.stdout.splitlines()]
        assert any(v.get('action',{}).get('text')=='HELLO' for v in output)
        print('Verified cloud/remote/redirect refusal before prompts, local AI, complete cached availability, aliases, category dispatch gating, native settings, checksum installs, and real WASM execution.')
    finally:server.shutdown();server.server_close()
