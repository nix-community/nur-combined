"""Deterministic desktop notification receiver for the VM integration tests."""
import json

import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

INTERFACE = "org.freedesktop.Notifications"
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)


class Receiver(dbus.service.Object):
    @dbus.service.method(INTERFACE, in_signature="", out_signature="as")
    def GetCapabilities(self):
        return ["body", "actions", "body-markup"]

    @dbus.service.method(INTERFACE, in_signature="", out_signature="ssss")
    def GetServerInformation(self):
        return ("Miodroid VM receiver", "Miodroid", "1", "1.2")

    @dbus.service.method(INTERFACE, in_signature="susssasa{sv}i", out_signature="u")
    def Notify(self, app, replaces, icon, summary, body, actions, hints, expiry):
        with open("/tmp/miodroid-notifications.jsonl", "a") as output:
            output.write(json.dumps({"app": str(app), "summary": str(summary), "body": str(body)}) + "\n")
        return replaces or 1

    @dbus.service.method(INTERFACE, in_signature="u", out_signature="")
    def CloseNotification(self, identifier):
        self.NotificationClosed(identifier, 3)

    @dbus.service.signal(INTERFACE, signature="uu")
    def NotificationClosed(self, identifier, reason):
        pass

    @dbus.service.signal(INTERFACE, signature="us")
    def ActionInvoked(self, identifier, action):
        pass

    @dbus.service.signal(INTERFACE, signature="us")
    def ActivationToken(self, identifier, token):
        pass


name = dbus.service.BusName(INTERFACE, dbus.SessionBus())
receiver = Receiver(name, "/org/freedesktop/Notifications")
GLib.MainLoop().run()
