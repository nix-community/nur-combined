# evolution-data-server (e-d-s) exposes DBus services for managing contacts and calendars.
#
# TODO: setup plaintext backend (e.g. vcard import/export; or CardDAV with a plaintext backend like radicale)
#
# common users include:
# - `folks` (for contacts only, used in turn by `gnome-calls`, `gnome-contacts`, et al.)
# - `gnome-calendars`, along with several other calendar or todo/tasking apps
#
# by default, e-d-s can interface with:
# - addressbooks:
#   - local (~/.local/share/evolution/addressbook/system/{contacts.db,photos}
#     - sqlite db
#   - LDAP
#   - CardDAV
# - calendars:
#   - CalDAV
#   - contacts (meta "birthdays" and "anniversaries" calendars populated from fields in whatever addressbooks e-d-s was configured for)
#   - file (~/.local/share/evolution/calendar/system/calendar.ics)
#   - gtasks (Google Tasks webservice)
#   - http (webcal; might be nerfed?)
#   - weather (gweather)
#     - weather for the current day, plus a daily forecast: temperature low/high, fog/clouds/overcast/snow/storm, textual summary
#   - webdav-notes (.txt or .md)
# - it also has a pluggable backend system ("extensions"), though external extensions are very difficult to find.
#   - evolution-ews extension adds Microsoft Exchange support
#   - evolution itself acts as an extension
#   the internals/data flow are obtuse enough that writing an extension in C is a *bad* idea
#   however e-d-s has gobject-introspection (g-i-r) bindings; it *may* be possible to write extensions in Python.
#
# utilities:
# - `libexec/evolution-data-server/addressbook-export` can (supposedly) export an address book to vcard or csv format
# - `src/examples/cursor/cursor-example` (not installed) when run will import a directory of .vcf cards into a `local` addressbook (creating the addressbook if it doesn't exist)
# - `evolution /path/to/vcard.vcf` imports a vcf into the primary e-d-s addressbook, but requires UI interaction
# - `gnome-contacts-parser vcard /my/vcard.vcf` from ${gnome-contacts}/libexec/gnome-contacts: transforms a vcard into a gvariant
#     that's used internally; there doesn't appear a way to plumb that gvariant down into the database without going through the UI
#
# noteworthy build-time config options:
# - ENABLA_VALA_BINDINGS
# - ENABLE_BACKEND_PER_PROCESS
# - ENABLE_BACKTRACES
# - ENABLE_EXAMPLES  (it's got an example that maybe imports vcards from a directory)
# - ENABLE_GOA
# - ENABLE_GTK  (for gtk3)
# - ENABLE_GTK4
# - ENABLE_OAUTH2_WEBKITGTK
# - ENABLE_OAUTH2_WEBKITGTK4
# - WITH_PRIVATE_DOCS
#
# noteworthy environment variables:
# - BOOKSQL_DEBUG
# - CALDAV_DEBUG
# - CARDDAV_DEBUG
# - EAN_DEBUG
# - EBSQL_DEBUG
# - EDS_ADDRESS_BOOK_MODULES  (allows overriding the `file` backend with your own .so implementation)
# - EDS_CALENDAR_MODULES
# - EDS_EXTRA_PREFIXES
# - EDS_REGISTRY_MODULES
# - EDS_SUBPROCESS_BOOK_PATH
# - EDS_SUBPROCESS_CAL_PATH
# - EDS_TESTING
# - ERW_DEBUG
# - ESR_DEBUG
# - GDATA_DEBUG
# - GOA_DEBUG
# - LDAP_DEBUG
# - LDAP_TIMEOUT
# - OAUTH2_DEBUG
# - WEBCAL_DEBUG
# - WEBDAV_DEBUG
# - WEBDAV_NOTES_DEBUG
{ config, pkgs, ... }:
let
  cfg = config.sane.programs."evolution-data-server";
in
{
  sane.programs."evolution-data-server" = {
    packageUnwrapped = pkgs.evolution-data-server.override {
      # disable the UI; avoid a dep on webkitgtk (if this is too blunt, specify `enableOAuth2 = false;` instead)
      withGtk3 = false;
      withGtk4 = false;
    };

    sandbox.whitelistDbus = [ "user" ];

    persist.byStore.ephemeral = [
      ".cache/evolution"
      # ~/.config/evolution/sources:
      # - birthdays.source
      # - system-calendar.source
      # - system-proxy.source
      ".config/evolution/sources"
    ];
    persist.byStore.private = [
      # local data stores (e.g. addressbook, calendar) live in ~/.local/share/evolution
      ".local/share/evolution"
    ];

    # e-d-s provides the following services:
    # - evolution-addressbook-factory  (org.gnome.evolution.dataserver.AddressBook10)
    # - evolution-calendar-factory  (org.gnome.evolution.dataserver.Calendar8)
    # - evolution-source-registry  (org.gnome.evolution.dataserver.Sources5)
    # - evolution-user-prompter  (org.gnome.evolution.dataserver.UserPrompter0)
    services."evolution-addressbook-factory" = {
      # evolution-addressbook-factory is required for gnome-contacts to add/view contacts
      description = "evolution-addressbook-factory provides contacts storage/retrieval to dbus users";
      dependencyOf = [ "graphical-session" ];
      command = "${cfg.package}/libexec/evolution-addressbook-factory --keep-running";
      readiness.waitDbus = "org.gnome.evolution.dataserver.AddressBook10";
    };
    services."evolution-calendar-factory" = {
      # evolution-addressbook-factory is required by gnome-calendar to add/view events
      description = "evolution-calendar-factory provides calendar storage/retrieval to dbus users";
      dependencyOf = [ "graphical-session" ];
      command = "${cfg.package}/libexec/evolution-calendar-factory --keep-running";
      readiness.waitDbus = "org.gnome.evolution.dataserver.Calendar8";
    };
    services."evolution-source-registry" = {
      # evolution-source-registry sits between consumers and sources;
      # without it the addressbook-factory and calendar-factory are effectively useless.
      description = "evolution-source-registry provides a list of available contacts/calendar sources to dbus users";
      dependencyOf = [ "graphical-session" ];
      command = "${cfg.package}/libexec/evolution-source-registry";
      readiness.waitDbus = "org.gnome.evolution.dataserver.Sources5";
    };
    # services."evolution-user-prompter" = ...  #< seems to not be required
  };
}
