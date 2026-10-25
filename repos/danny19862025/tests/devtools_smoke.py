#!/usr/bin/python3
"""Editor metadata, SSH/GitHub argv, dotenv, and native snippet/inspector checks."""
import json
import os
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile

project = Path(__file__).resolve().parents[1]
if '--inside' not in sys.argv:
    with tempfile.TemporaryDirectory(prefix='spotlight-devtools-bus-') as directory:
        config = Path(directory) / 'session.conf'
        config.write_text('''<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig><type>session</type><listen>unix:tmpdir=/tmp</listen><auth>EXTERNAL</auth><policy context="default"><allow own="*"/><allow send_destination="*"/><allow receive_sender="*"/></policy></busconfig>''')
        raise SystemExit(subprocess.call(['dbus-run-session', '--config-file='+str(config), '--', '/usr/bin/python3', __file__, '--inside', *sys.argv[1:]], cwd=project))

stub = r'''#!/usr/bin/python3
import json, os, pathlib, sys
root=pathlib.Path(os.environ['SPOTLIGHT_DEVTOOLS_ROOT']);tool=pathlib.Path(sys.argv[0]).name
with (root/'calls.jsonl').open('a') as f: f.write(json.dumps({'tool':tool,'args':sys.argv[1:],'cwd':os.getcwd()})+'\n')
if tool=='gh':
    assert 'GH_REPO' not in os.environ
    assert sys.argv[1] in ('pr','issue') and sys.argv[2]=='list'
    print(json.dumps([{'number':12,'title':'Fix café','state':'OPEN','url':'https://github.com/owner/demo/pull/12'}]))
'''

with tempfile.TemporaryDirectory(prefix='spotlight-devtools-') as directory:
    root=Path(directory);home=root/'home';config=root/'config';data=root/'data';tools=root/'bin'
    for path in [home,config,data,tools]: path.mkdir()
    code=root/'my project café';idea=root/'JetBrains project';code.mkdir();idea.mkdir()
    (home/'Projects').mkdir();(home/'Projects/demo').symlink_to(code,target_is_directory=True)
    workspace=root/'DemoWorkspace.code-workspace';workspace.write_text(json.dumps({'folders':[{'path':str(code)}]}))
    subprocess.run(['git','init','--quiet',str(code)],check=True)
    (code/'.env').write_text("API_KEY=dotenv-private-value\nexport HELLO='world'\n")
    storage=config/'Code/User/globalStorage';storage.mkdir(parents=True)
    recent={'entries':[{'folderUri':code.as_uri()},{'workspace':{'configPath':workspace.as_uri()}},{'folderUri':(root/'missing').as_uri()},
                       {'folderUri':'vscode-remote://ssh-remote+host/project'}]}
    with sqlite3.connect(storage/'state.vscdb') as connection:
        connection.execute('CREATE TABLE ItemTable (key TEXT PRIMARY KEY, value TEXT)')
        connection.execute('INSERT INTO ItemTable VALUES (?,?)',('history.recentlyOpenedPathsList',json.dumps(recent)))
    (storage/'storage.json').write_text(json.dumps({'openedPathsList':{'workspaces3':[code.as_uri()]}}))
    recents=config/'JetBrains/PyCharm2026.2/options';recents.mkdir(parents=True)
    import xml.sax.saxutils
    escaped=xml.sax.saxutils.escape(str(idea),{'"':'&quot;'})
    (recents/'recentProjects.xml').write_text(f'<application><component><option name="additionalInfo"><map><entry key="{escaped}"/></map></option></component></application>')
    (home/'.ssh/hosts').mkdir(parents=True)
    (home/'.ssh/config').write_text('Host myserver second\n HostName example.invalid\nHost * !excluded\nInclude hosts/*.conf\n')
    (home/'.ssh/hosts/demo.conf').write_text('Host included\nInclude config\n')
    for name in ['code','pycharm','konsole','gh']:
        path=tools/name;path.write_text(stub);path.chmod(0o755)
    build=subprocess.run(['cargo','test','--offline','--no-run','--message-format=json'],cwd=project,text=True,capture_output=True,check=True)
    binaries=[v['executable'] for line in build.stdout.splitlines() if (v:=json.loads(line)).get('executable') and v.get('profile',{}).get('test')]
    assert binaries
    env=dict(os.environ,HOME=str(home),XDG_CONFIG_HOME=str(config),XDG_DATA_HOME=str(data),XDG_CACHE_HOME=str(root/'cache'),
             SPOTLIGHT_DEVTOOLS_ROOT=str(root),SPOTLIGHT_TEST_SECRET='private-fixture-value',
             GH_REPO='unrelated/wrong-repository',
             PATH=str(tools)+os.pathsep+os.environ['PATH'],GSK_RENDERER='cairo',GIO_USE_VFS='local',
             GTK_A11Y='none',NO_AT_BRIDGE='1',GSETTINGS_BACKEND='memory')
    env.pop('SPOTLIGHT_PROJECT_DIR',None)
    for name in ['devtools::tests::fixtures','devtools_smoke::native_ui']:
        # Restore aliases changed by the stale-target backend check.
        (home/'.ssh/config').write_text('Host myserver second\nInclude hosts/*.conf\n')
        with (root/'output.log').open('w+') as output:
            result=subprocess.run([binaries[0],name,'--ignored','--exact','--test-threads=1','--nocapture'],cwd=project,env=env,stdout=output,stderr=output,timeout=45)
            output.seek(0);report=output.read()
        if result.returncode:
            Path('/tmp/spotlight-devtools-failure.log').write_text(report)
            print(report[:2200]+'\n'+report[-800:]);raise SystemExit(result.returncode)
        print(name+': PASS',flush=True)
    calls=[json.loads(line) for line in (root/'calls.jsonl').read_text().splitlines()]
    assert any(c['tool']=='code' and c['args']==[str(code)] for c in calls)
    assert any(c['tool']=='pycharm' and c['args']==[str(idea)] for c in calls)
    assert any(c['tool']=='konsole' and c['args']==['--separate','-e','ssh','--','myserver'] for c in calls)
    github=[c for c in calls if c['tool']=='gh']
    assert any(c['args'][:2]==['pr','list'] and c['cwd']==str(code) for c in github)
    assert any(c['args'][-4:]==['--repo','owner/demo','--search','label:bug shell; $(nope)'] for c in github)
    assert not (project/'nope').exists()
    assert not any('private-fixture-value' in json.dumps(c) or 'dotenv-private-value' in json.dumps(c) for c in calls)
    print('Verified read-only editor recents, exact SSH/GitHub arguments, private environment inspection, project context, and Unicode/clipboard snippet expansion.')
