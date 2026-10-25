#!/usr/bin/env python3
"""Exercise expanded tools with private CLI/D-Bus fixtures and real QR/OCR helpers."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

project = Path(__file__).resolve().parents[1]
if '--inside' not in sys.argv:
    with tempfile.TemporaryDirectory(prefix='spotlight-test-bus-') as bus_directory:
        config=Path(bus_directory)/'session.conf'
        config.write_text('''<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig><type>session</type><listen>unix:tmpdir=/tmp</listen><auth>EXTERNAL</auth><policy context="default"><allow own="*"/><allow send_destination="*"/><allow receive_sender="*"/></policy></busconfig>''')
        raise SystemExit(subprocess.call(['dbus-run-session', '--config-file='+str(config), '--', '/usr/bin/python3', str(Path(__file__).resolve()), '--inside', *sys.argv[1:]], cwd=project))

import cairo
from gi.repository import Gio, GLib

STUB = r'''#!/usr/bin/python3
import json, os, pathlib, sys
root=pathlib.Path(os.environ['SPOTLIGHT_FEATURE_ROOT'])
tool=pathlib.Path(sys.argv[0]).name;args=sys.argv[1:]
with (root/'calls.jsonl').open('a') as f: f.write(json.dumps([tool,args])+'\n')
if tool=='ip':
 print(json.dumps([{'ifname':'eth0','addr_info':[{'local':'192.0.2.10','scope':'global'},{'local':'127.0.0.1','scope':'host'}]}]))
elif tool=='curl':
 if args[-1]=='https://api.ipify.org': print('203.0.113.20')
 elif '/json/list' in args[-1]: print(json.dumps([{'type':'page','id':'tab-ABC123','title':'Rust documentation','url':'https://www.rust-lang.org/'}]))
 elif '/json/activate/tab-ABC123' in args[-1]: print('Target activated')
 else: raise RuntimeError(args)
elif tool=='pactl':
 if (root/'pactl-disabled').exists(): sys.exit(1)
 if args==['get-default-sink']: print('speakers')
 elif args==['-f','json','list','sinks']: print(json.dumps([{'name':'speakers','description':'Speakers','state':'RUNNING'},{'name':'headphones','description':'Headphones','state':'IDLE'}]))
 elif args==['-f','json','list','sink-inputs']: print(json.dumps([{'index':17}]))
 else: assert args[0] in ['set-default-sink','move-sink-input']
elif tool=='wpctl':
 if args==['status']: print('Audio\n ├─ Sinks:\n │ * 52. Headphones [vol: 0.40]\n ├─ Sources:\nVideo\n')
 elif args==['inspect','52']:
  print('node.name = "'+('new-device' if (root/'wpctl-changed').exists() else 'headphones-node')+'"\nmedia.class = "Audio/Sink"')
 else: assert args==['set-default','52']
elif tool=='apt-cache': print('demo-app - A demonstration package')
elif tool=='pacman':
 assert args[:1]==['-Ss']; print('extra/demo-app 1.0-1\n    A demonstration package')
elif tool=='flatpak':
 if args[0]=='search':
  if args[-1]!='dmo': print('org.example.Demo\tDemo App\tA demonstration package\t1.0\tflathub')
 elif args[0]=='remotes': print('flathub')
 else: assert args[:1]==['install']
elif tool=='pkexec':
 assert args[0] in ['apt-get','pacman','systemctl'];print('Fixture action completed')
elif tool=='systemctl':
 if 'list-units' in args: print(json.dumps([{'unit':'demo.service','active':'active','sub':'running','description':'Demo worker'},{'unit':'docker.service','active':'inactive','sub':'dead','description':'Docker'}]))
 elif 'show' in args: print('Id=demo.service\nActiveState=active\nSubState=running\nMainPID=123')
 else: assert 'restart' in args or 'start' in args or 'stop' in args
elif tool=='bluetoothctl':
 if args==['devices']: print('Device AA:BB:CC:11:22:33 AirPods\nDevice AA:BB:CC:44:55:66 Keyboard')
 elif args==['devices','Connected']: print('Device AA:BB:CC:44:55:66 Keyboard')
 else: assert args==['--timeout','15','connect','AA:BB:CC:11:22:33']
elif tool=='dolphin': assert args[0]=='--select'
else: raise RuntimeError(tool)
'''

fixture_parent=Path.home()
with tempfile.TemporaryDirectory(prefix='spotlight-features-',dir=fixture_parent) as directory:
    root=Path(directory);tools=root/'bin';tools.mkdir()
    for name in ['ip','curl','pactl','wpctl','apt-cache','pacman','flatpak','pkexec','systemctl','bluetoothctl','dolphin']:
        path=tools/name;path.write_text(STUB);path.chmod(0o755)
    for name in ['tesseract']:
        if not shutil.which(name): raise SystemExit(f'Install {name} to run the real image-tool verification.')
    data=root/'data';config=root/'config';data.mkdir();config.mkdir()
    (data/'spotlight').mkdir();(data/'spotlight/data.json').write_text(json.dumps({'obsidian_disabled':True}))
    pictures=root/'Pictures/Screenshots';pictures.mkdir(parents=True)
    (config/'user-dirs.dirs').write_text(f'XDG_PICTURES_DIR="{root / "Pictures"}"\n')
    (root/'file café # & demo.txt').write_text('A plain text fixture.\n')
    image=cairo.ImageSurface(cairo.FORMAT_RGB24,1100,180);context=cairo.Context(image)
    context.set_source_rgb(1,1,1);context.paint();context.set_source_rgb(0,0,0)
    context.select_font_face('DejaVu Sans',cairo.FONT_SLANT_NORMAL,cairo.FONT_WEIGHT_BOLD);context.set_font_size(66);context.move_to(45,115);context.show_text('Spotlight 2026')
    image.write_to_png(str(root/'ocr.png'));shutil.copyfile(root/'ocr.png',pictures/'Screenshot Demo.png')
    env=dict(os.environ,SPOTLIGHT_FEATURE_ROOT=str(root),SPOTLIGHT_CHROME_DEBUG_PORT="9222",XDG_DATA_HOME=str(data),XDG_CONFIG_HOME=str(config),XDG_CACHE_HOME=str(root/'cache'),PATH=str(tools)+os.pathsep+os.environ['PATH'],GIO_USE_VFS='local',GSK_RENDERER='cairo',NO_AT_BRIDGE='1',GTK_A11Y='none',GSETTINGS_BACKEND='memory')
    bus=Gio.bus_get_sync(Gio.BusType.SESSION,None)
    klipper_calls=[]
    xml='''<node><interface name="org.kde.klipper.klipper">
      <method name="clearClipboardHistory"/><method name="clearClipboardContents"/>
      <method name="getClipboardHistoryMenu"><arg type="as" direction="out"/></method>
      <method name="getClipboardHistoryItem"><arg type="i" direction="in"/><arg type="s" direction="out"/></method>
    </interface></node>'''
    def method(connection,sender,path,interface,name,parameters,invocation):
        klipper_calls.append(name)
        with (root/'dbus-calls.jsonl').open('a') as f:f.write(json.dumps(name)+'\n')
        if name=='getClipboardHistoryMenu':invocation.return_value(GLib.Variant('(as)',(['Fixture clipboard text'],)))
        elif name=='getClipboardHistoryItem':invocation.return_value(GLib.Variant('(s)',('Fixture clipboard text',)))
        else:invocation.return_value(None)
    bus.register_object('/klipper',Gio.DBusNodeInfo.new_for_xml(xml).interfaces[0],method,None,None)
    reply=bus.call_sync('org.freedesktop.DBus','/org/freedesktop/DBus','org.freedesktop.DBus','RequestName',GLib.Variant('(su)',('org.kde.klipper',0)),None,Gio.DBusCallFlags.NONE,2000,None)
    assert reply.unpack()[0]==1
    # Screenshot portal fixture returns a disposable capture and records every request.
    portal_xml='<node><interface name="org.freedesktop.portal.Screenshot"><method name="Screenshot"><arg type="s" direction="in"/><arg type="a{sv}" direction="in"/><arg type="o" direction="out"/></method></interface></node>'
    def screenshot(connection,sender,path,interface,name,parameters,invocation):
        parent,options=parameters.unpack();assert options['interactive'] is True
        request='/org/freedesktop/portal/desktop/request/'+sender.lstrip(':').replace('.','_')+'/'+options['handle_token']
        count=root/'portal-count';number=int(count.read_text())+1 if count.exists() else 1;count.write_text(str(number))
        capture=root/f'portal-capture-{number}.png';shutil.copyfile(root/'chain.png' if (root/'chain.png').exists() else root/'ocr.png',capture)
        invocation.return_value(GLib.Variant('(o)',(request,)))
        def respond():
            connection.emit_signal(sender,request,'org.freedesktop.portal.Request','Response',GLib.Variant('(ua{sv})',(0,{'uri':GLib.Variant('s',capture.as_uri())})));return False
        GLib.timeout_add(100,respond)
    bus.register_object('/org/freedesktop/portal/desktop',Gio.DBusNodeInfo.new_for_xml(portal_xml).interfaces[0],screenshot,None,None)
    bus.call_sync('org.freedesktop.DBus','/org/freedesktop/DBus','org.freedesktop.DBus','RequestName',GLib.Variant('(su)',('org.freedesktop.portal.Desktop',0)),None,Gio.DBusCallFlags.NONE,2000,None)
    names=['advanced::tests::fixture_backends']
    if '--ui' in sys.argv:names.extend(['features_smoke::native_ui', 'localtools_ui::tests::native_ui', 'localtools_ui::tests::screenshot_chain'])
    for name in names:
        with (root/'output.log').open('w+') as output:
            command=['cargo','test','--offline',name,'--','--ignored','--exact','--test-threads=1','--nocapture']
            process=subprocess.Popen(command,cwd=project,env=env,stdout=output,stderr=output)
            loop=GLib.MainLoop();expired=[False]
            def poll():
                if process.poll() is None:return True
                loop.quit();return False
            def timeout():
                expired[0]=True;process.kill();loop.quit();return False
            GLib.timeout_add(50,poll);timer=GLib.timeout_add_seconds(120,timeout);loop.run()
            if not expired[0]:GLib.source_remove(timer)
            process.wait();output.seek(0);report=output.read()
            if process.returncode:
                Path('/tmp/spotlight-feature-test-failure.log').write_text(report)
                lines=report.splitlines();selected=set(range(min(15,len(lines))))
                for i,line in enumerate(lines):
                    if 'panicked at' in line or 'assertion' in line or 'RefCell' in line:selected.update(range(max(0,i-3),min(len(lines),i+8)))
                print('\n'.join(lines[i] for i in sorted(selected)))
            else:print(report,end='')
            assert not expired[0] and process.returncode==0, f'{name} failed'
    calls=[json.loads(line) for line in (root/'calls.jsonl').read_text().splitlines()]
    assert any(tool=='pkexec' and args[:3]==['apt-get','install','-y'] and args[-1]=='demo-app' for tool,args in calls)
    assert any(tool=='pkexec' and args[0]=='pacman' and args[-1]=='demo-app' for tool,args in calls)
    assert any(tool=='flatpak' and args[:2]==['install','--user'] and args[-1]=='org.example.Demo' for tool,args in calls)
    assert any(tool=='pactl' and args==['set-default-sink','headphones'] for tool,args in calls)
    assert any(tool=='pactl' and args==['move-sink-input','17','headphones'] for tool,args in calls)
    assert any(tool=='wpctl' and args==['set-default','52'] for tool,args in calls)
    assert any(tool=='systemctl' and args==['--user','restart','--','demo.service'] for tool,args in calls)
    assert any(tool=='bluetoothctl' and args[-2:]==['connect','AA:BB:CC:11:22:33'] for tool,args in calls)
    assert any(tool=='dolphin' and args==['--select',str(root/'file café # & demo.txt')] for tool,args in calls)
    assert klipper_calls.count('clearClipboardHistory')==1 and klipper_calls.count('clearClipboardContents')==1
    print('Isolated fixtures verified exact arguments; no system packages, services, devices, or real clipboard history were changed.')
