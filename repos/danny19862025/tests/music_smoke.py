#!/usr/bin/env python3
"""Native D-Bus controls against a private MPRIS service; personal playback is untouched."""
import os
from pathlib import Path
import subprocess
import sys

if '--inside' not in sys.argv:
    raise SystemExit(subprocess.call(['dbus-run-session', '--', '/usr/bin/python3', __file__, '--inside']))

from gi.repository import Gio, GLib
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
xml = '''<node>
<interface name="org.mpris.MediaPlayer2">
<property name="Identity" type="s" access="read"/>
<property name="CanQuit" type="b" access="read"/>
<property name="CanRaise" type="b" access="read"/>
<property name="SupportedUriSchemes" type="as" access="read"/>
<property name="SupportedMimeTypes" type="as" access="read"/>
</interface>
<interface name="org.mpris.MediaPlayer2.Player">
<method name="Next"/><method name="Pause"/><method name="Play"/><method name="PlayPause"/><method name="Stop"/><method name="Previous"/>
<property name="PlaybackStatus" type="s" access="read"/>
<property name="Metadata" type="a{sv}" access="read"/>
<property name="CanControl" type="b" access="read"/>
<property name="CanPlay" type="b" access="read"/>
<property name="CanPause" type="b" access="read"/>
<property name="CanGoNext" type="b" access="read"/>
<property name="CanGoPrevious" type="b" access="read"/>
</interface></node>'''
methods = []
can_pause = [True]
def call(_c, _s, _p, _i, method, _a, invocation):
    methods.append(method)
    if method=='Pause':can_pause[0]=False
    invocation.return_value(None)
def get(_c, _s, _p, _i, prop):
    if prop == 'CanPause':return GLib.Variant('b',can_pause[0])
    if prop == 'CanGoPrevious':return GLib.Variant('b',False)
    if prop == 'Metadata':
        return GLib.Variant('a{sv}', {'xesam:artist': GLib.Variant('as', ['Fixture artist']), 'xesam:title': GLib.Variant('s', 'Fixture song')})
    if prop in ['PlaybackStatus', 'Identity']:
        return GLib.Variant('s', 'Playing' if prop == 'PlaybackStatus' else 'Spotlight Fixture')
    if prop.startswith('Supported'):
        return GLib.Variant('as', [])
    return GLib.Variant('b', True)
for interface in Gio.DBusNodeInfo.new_for_xml(xml).interfaces:
    bus.register_object('/org/mpris/MediaPlayer2', interface, call, get, None)
bus.call_sync('org.freedesktop.DBus', '/org/freedesktop/DBus', 'org.freedesktop.DBus', 'RequestName', GLib.Variant('(su)', ('org.mpris.MediaPlayer2.spotlight_fixture', 0)), None, Gio.DBusCallFlags.NONE, 1000, None)
project = Path(__file__).resolve().parents[1]
process = subprocess.Popen(['cargo', 'test', '--offline', 'localtools::music_fixture::native_mpris_controls', '--', '--ignored', '--exact', '--nocapture'], cwd=project, env=dict(os.environ, SPOTLIGHT_MUSIC_FIXTURE='1'))
loop = GLib.MainLoop()
def poll():
    if process.poll() is None:
        return True
    loop.quit()
    return False
GLib.timeout_add(100, poll)
def timeout():
    process.kill()
    loop.quit()
    return False
watchdog = GLib.timeout_add_seconds(30, timeout)
loop.run()
GLib.source_remove(watchdog)
assert process.wait() == 0
assert methods == ['Next', 'PlayPause', 'Pause', 'Play'], methods
print('Native MPRIS discovery, metadata, Play/Pause/Next, capability filtering and revalidation passed on a private bus.')
