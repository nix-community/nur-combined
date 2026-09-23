/*
  A stand-in for GConf (libgconf-2.so.4), which Chromium 50 links against.

  Chromium 50 uses GConf for one thing only: reading the window button layout and
  the non client middle click action of the window manager from
  /apps/metacity/general (see chrome/browser/ui/libgtk2ui/gconf_listener.cc).
  That code runs only on GNOME and Unity desktops or under Metacity, and it
  explicitly falls back to Chromium's own defaults when it cannot obtain a GConf
  client, which is exactly what the real library does when it cannot reach the
  GConf daemon:

    client_ = gconf_client_get_default();
    // If we fail to get a context, that's OK, since we'll just fallback on
    // not receiving gconf keys.
    if (client_) { ... }

  GConf is not available in nixpkgs anymore: its only implementation is built on
  ORBit2, an unmaintained CORBA library that does not build with a modern
  toolchain.  This shim therefore implements the small part of the GConf client
  interface that Chromium 50 uses with the semantics of a GConf installation
  that has no settings: gconf_client_get_default() returns NULL and every other
  function reports that no value is set.  None of the functions dereference
  their arguments, so they are also safe to call with the NULL client.

  The result is that Chromium 50 keeps its own defaults for the window button
  layout and the middle click action, just like it does on any desktop that is
  not GNOME, Unity or Metacity.

  This file is an original implementation of the interface, not derived from
  GConf's sources.
*/

#include <stddef.h>

typedef int gboolean;
typedef unsigned int guint;

typedef struct GConfClient GConfClient;
typedef struct GConfValue GConfValue;
typedef struct GConfEntry GConfEntry;
typedef struct GSList GSList;
typedef struct GError GError;

GConfClient *gconf_client_get_default(void)
{
  return NULL;
}

void gconf_client_add_dir(GConfClient *client, const char *dir, int preload,
                          GError **error)
{
}

void gconf_client_remove_dir(GConfClient *client, const char *dir, GError **error)
{
}

guint gconf_client_notify_add(GConfClient *client, const char *key,
                              void (*func)(GConfClient *, guint, GConfEntry *, void *),
                              void *user_data, void (*destroy_notify)(void *),
                              GError **error)
{
  return 0;
}

void gconf_client_notify_remove(GConfClient *client, guint cnxn)
{
}

GConfValue *gconf_client_get(GConfClient *client, const char *key, GError **error)
{
  return NULL;
}

gboolean gconf_client_get_bool(GConfClient *client, const char *key, GError **error)
{
  return 0;
}

int gconf_client_get_int(GConfClient *client, const char *key, GError **error)
{
  return 0;
}

char *gconf_client_get_string(GConfClient *client, const char *key, GError **error)
{
  return NULL;
}

GSList *gconf_client_get_list(GConfClient *client, const char *key, int list_type,
                              GError **error)
{
  return NULL;
}

const char *gconf_entry_get_key(const GConfEntry *entry)
{
  return NULL;
}

GConfValue *gconf_entry_get_value(const GConfEntry *entry)
{
  return NULL;
}

const char *gconf_value_get_string(const GConfValue *value)
{
  return NULL;
}

gboolean gconf_value_get_bool(const GConfValue *value)
{
  return 0;
}

void gconf_value_free(GConfValue *value)
{
}
