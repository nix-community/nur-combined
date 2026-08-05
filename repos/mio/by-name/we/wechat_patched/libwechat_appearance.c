/*
 * LD_PRELOAD interceptor: make Linux WeChat follow the desktop color scheme.
 *
 * Official WeChat only exposes light/dark in settings. Internally it still has a
 * "system" path, but the detector stub always returns light (xor eax,eax; ret).
 * We hook the appearance-apply function (unique prologue) and force mode from
 * xdg-desktop-portal org.freedesktop.appearance color-scheme (Plasma/GNOME).
 *
 * Modes (esi): 1 = light, 2 = dark.
 * Portal: 0 = no preference, 1 = prefer dark, 2 = prefer light.
 *
 * Disable: WECHAT_APPEARANCE_FOLLOW=0
 * Debug:   WECHAT_APPEARANCE_DEBUG=1
 * Live:    WECHAT_APPEARANCE_LIVE=0 to skip portal change notifications
 */
#define _GNU_SOURCE
#include <dbus/dbus.h>
#include <errno.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define LOG(fmt, ...)                                                          \
  do {                                                                         \
    if (debug_enabled)                                                         \
      fprintf(stderr, "wechat-appearance: " fmt "\n", ##__VA_ARGS__);          \
  } while (0)

/* push rbx; sub rsp,0x140; cmp byte [rdi+0x80],0 — unique in 4.1.1.4 */
static const uint8_t apply_sig[] = {0x53, 0x48, 0x81, 0xec, 0x40, 0x01, 0x00,
                                    0x00, 0x80, 0xbf, 0x80, 0x00, 0x00, 0x00,
                                    0x00};
enum { STOLEN = 15 }; /* matches apply_sig length / instruction boundary */

static bool debug_enabled;
static bool follow_enabled = true;
static bool live_enabled = true;

static void (*orig_apply)(void *, int);
static atomic_uintptr_t last_obj;
static atomic_int in_hook;
static atomic_int last_mode; /* 1 or 2 */
static atomic_int cached_scheme; /* portal uint32, or -1 unknown */

static int env_flag(const char *name, int default_val) {
  const char *v = getenv(name);
  if (!v || !*v)
    return default_val;
  if (v[0] == '0' && v[1] == '\0')
    return 0;
  return 1;
}

/* --- portal color-scheme ------------------------------------------------- */

static DBusConnection *session_bus(void) {
  static DBusConnection *conn;
  static bool tried;
  if (tried)
    return conn;
  tried = true;
  DBusError err;
  dbus_error_init(&err);
  conn = dbus_bus_get(DBUS_BUS_SESSION, &err);
  if (!conn) {
    LOG("no session bus: %s", err.message ? err.message : "?");
    dbus_error_free(&err);
  }
  return conn;
}

static int read_portal_color_scheme(DBusConnection *conn) {
  DBusMessage *msg = dbus_message_new_method_call(
      "org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop",
      "org.freedesktop.portal.Settings", "Read");
  if (!msg)
    return -1;

  const char *ns = "org.freedesktop.appearance";
  const char *key = "color-scheme";
  if (!dbus_message_append_args(msg, DBUS_TYPE_STRING, &ns, DBUS_TYPE_STRING,
                                &key, DBUS_TYPE_INVALID)) {
    dbus_message_unref(msg);
    return -1;
  }

  DBusError err;
  dbus_error_init(&err);
  DBusMessage *reply =
      dbus_connection_send_with_reply_and_block(conn, msg, 2000, &err);
  dbus_message_unref(msg);
  if (!reply) {
    LOG("portal Read failed: %s", err.message ? err.message : "?");
    dbus_error_free(&err);
    return -1;
  }

  /* Reply is variant(variant(uint32)) for Settings.Read */
  DBusMessageIter iter, var1, var2;
  dbus_message_iter_init(reply, &iter);
  if (dbus_message_iter_get_arg_type(&iter) != DBUS_TYPE_VARIANT) {
    dbus_message_unref(reply);
    return -1;
  }
  dbus_message_iter_recurse(&iter, &var1);
  if (dbus_message_iter_get_arg_type(&var1) != DBUS_TYPE_VARIANT) {
    dbus_message_unref(reply);
    return -1;
  }
  dbus_message_iter_recurse(&var1, &var2);
  if (dbus_message_iter_get_arg_type(&var2) != DBUS_TYPE_UINT32) {
    dbus_message_unref(reply);
    return -1;
  }
  dbus_uint32_t cs = 0;
  dbus_message_iter_get_basic(&var2, &cs);
  dbus_message_unref(reply);
  return (int)cs;
}

/* Fallback when portal is missing (non-bwrap). bwrap fake $HOME hides this. */
static int kde_is_dark(void) {
  const char *home = getenv("HOME");
  if (!home)
    return -1;
  char path[512];
  snprintf(path, sizeof path, "%s/.config/kdeglobals", home);
  FILE *f = fopen(path, "r");
  if (!f)
    return -1;
  char line[256];
  int dark = -1;
  while (fgets(line, sizeof line, f)) {
    if (strncmp(line, "ColorScheme=", 12) == 0) {
      for (char *p = line + 12; *p; p++) {
        if (*p >= 'A' && *p <= 'Z')
          *p += 32;
      }
      dark = strstr(line + 12, "dark") != NULL;
      break;
    }
  }
  fclose(f);
  return dark;
}

/* WeChat esi: 1 light, 2 dark */
static int scheme_to_wechat_mode(int cs) {
  /* 1 prefer-dark → 2; 0/2/unknown → light */
  return (cs == 1) ? 2 : 1;
}

static int portal_to_wechat_mode(void) {
  int cached = atomic_load(&cached_scheme);
  if (cached >= 0)
    return scheme_to_wechat_mode(cached);

  DBusConnection *conn = session_bus();
  int cs = conn ? read_portal_color_scheme(conn) : -1;
  if (cs < 0) {
    int k = kde_is_dark();
    LOG("portal unavailable, kde_is_dark=%d", k);
    cs = (k == 1) ? 1 : 2; /* synthesize portal-ish: 1 dark, 2 light */
    if (k < 0)
      cs = 2; /* default light */
  }

  atomic_store(&cached_scheme, cs);
  int mode = scheme_to_wechat_mode(cs);
  LOG("color-scheme=%d → wechat mode %d (%s)", cs, mode,
      mode == 2 ? "dark" : "light");
  return mode;
}

/* --- binary patch helpers ------------------------------------------------ */

static void *mem_search(const void *hay, size_t hay_len, const uint8_t *needle,
                        size_t nlen) {
  if (!hay || hay_len < nlen)
    return NULL;
  const uint8_t *p = hay;
  for (size_t i = 0; i + nlen <= hay_len; i++) {
    if (memcmp(p + i, needle, nlen) == 0)
      return (void *)(p + i);
  }
  return NULL;
}

/* Search every r-xp mapping whose pathname basename is "wechat". */
static void *find_apply_fn(void) {
  FILE *maps = fopen("/proc/self/maps", "r");
  if (!maps)
    return NULL;
  char line[512];
  void *found = NULL;
  while (fgets(line, sizeof line, maps)) {
    unsigned long start, end;
    char perms[8];
    if (sscanf(line, "%lx-%lx %7s", &start, &end, perms) != 3)
      continue;
    if (perms[0] != 'r' || perms[2] != 'x')
      continue;
    char *path = strchr(line, '/');
    if (!path)
      continue;
    size_t n = strlen(path);
    while (n > 0 && (path[n - 1] == '\n' || path[n - 1] == '\r'))
      path[--n] = 0;
    /* strip " (deleted)" */
    char *paren = strstr(path, " (deleted)");
    if (paren)
      *paren = 0;
    const char *base = strrchr(path, '/');
    if (!base || strcmp(base + 1, "wechat") != 0)
      continue;
    found = mem_search((void *)start, (size_t)(end - start), apply_sig,
                       sizeof apply_sig);
    if (found)
      break;
  }
  fclose(maps);
  return found;
}

static int mprotect_range(void *addr, size_t len, int prot) {
  uintptr_t page = (uintptr_t)addr & ~(uintptr_t)(getpagesize() - 1);
  uintptr_t end = ((uintptr_t)addr + len + getpagesize() - 1) &
                  ~(uintptr_t)(getpagesize() - 1);
  return mprotect((void *)page, end - page, prot);
}

static void apply_hook(void *obj, int mode) {
  atomic_store(&last_obj, (uintptr_t)obj);

  if (!follow_enabled) {
    orig_apply(obj, mode);
    return;
  }

  if (atomic_exchange(&in_hook, 1)) {
    /* Re-entrant (e.g. live reapply while applying): honor original mode. */
    orig_apply(obj, mode);
    return;
  }

  int m = portal_to_wechat_mode();
  atomic_store(&last_mode, m);
  orig_apply(obj, m);
  atomic_store(&in_hook, 0);
}

static int install_hook(void *target) {
  void *tramp = mmap(NULL, 64, PROT_READ | PROT_WRITE | PROT_EXEC,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (tramp == MAP_FAILED)
    return -1;

  uint8_t *t = tramp;
  memcpy(t, target, STOLEN);
  /* jmp qword ptr [rip+0]; abs64 back to target+STOLEN */
  t[STOLEN + 0] = 0xff;
  t[STOLEN + 1] = 0x25;
  memset(t + STOLEN + 2, 0, 4);
  uint64_t back = (uint64_t)((uint8_t *)target + STOLEN);
  memcpy(t + STOLEN + 6, &back, 8);

  orig_apply = (void (*)(void *, int))tramp;

  if (mprotect_range(target, 16, PROT_READ | PROT_WRITE | PROT_EXEC) != 0) {
    LOG("mprotect(RWX) failed: %s", strerror(errno));
    return -1;
  }

  uint8_t patch[15];
  patch[0] = 0xff;
  patch[1] = 0x25;
  memset(patch + 2, 0, 4);
  uint64_t hook = (uint64_t)(uintptr_t)apply_hook;
  memcpy(patch + 6, &hook, 8);
  patch[14] = 0x90; /* nop over leftover stolen byte */
  memcpy(target, patch, 15);

  /* Drop write again; keep execute. */
  if (mprotect_range(target, 16, PROT_READ | PROT_EXEC) != 0)
    LOG("mprotect(RX) failed: %s", strerror(errno));

  __builtin___clear_cache((char *)target, (char *)target + 15);
  LOG("hooked appearance apply at %p", target);
  return 0;
}

/* --- portal SettingChanged watcher --------------------------------------- */

static void reapply_from_portal(void) {
  void *obj = (void *)atomic_load(&last_obj);
  if (!obj || !orig_apply || !follow_enabled)
    return;
  if (atomic_exchange(&in_hook, 1))
    return;
  int m = portal_to_wechat_mode();
  int prev = atomic_load(&last_mode);
  if (m != prev) {
    LOG("live reapply mode %d → %d", prev, m);
    atomic_store(&last_mode, m);
    orig_apply(obj, m);
  }
  atomic_store(&in_hook, 0);
}

static DBusHandlerResult filter_cb(DBusConnection *conn, DBusMessage *msg,
                                   void *data) {
  (void)conn;
  (void)data;
  if (!dbus_message_is_signal(msg, "org.freedesktop.portal.Settings",
                              "SettingChanged"))
    return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;

  const char *ns = NULL, *key = NULL;
  DBusMessageIter iter;
  if (!dbus_message_iter_init(msg, &iter))
    return DBUS_HANDLER_RESULT_HANDLED;
  if (dbus_message_iter_get_arg_type(&iter) != DBUS_TYPE_STRING)
    return DBUS_HANDLER_RESULT_HANDLED;
  dbus_message_iter_get_basic(&iter, &ns);
  dbus_message_iter_next(&iter);
  if (dbus_message_iter_get_arg_type(&iter) != DBUS_TYPE_STRING)
    return DBUS_HANDLER_RESULT_HANDLED;
  dbus_message_iter_get_basic(&iter, &key);

  if (ns && key && strcmp(ns, "org.freedesktop.appearance") == 0 &&
      strcmp(key, "color-scheme") == 0) {
    /* Invalidate cache then re-read inside reapply. */
    atomic_store(&cached_scheme, -1);
    LOG("SettingChanged color-scheme");
    reapply_from_portal();
  }
  return DBUS_HANDLER_RESULT_HANDLED;
}

static void *portal_thread(void *arg) {
  (void)arg;
  DBusConnection *conn = session_bus();
  if (!conn) {
    LOG("portal thread: no bus");
    return NULL;
  }

  DBusError err;
  dbus_error_init(&err);
  dbus_bus_add_match(conn,
                     "type='signal',interface='org.freedesktop.portal.Settings',"
                     "member='SettingChanged'",
                     &err);
  if (dbus_error_is_set(&err)) {
    LOG("add_match: %s", err.message);
    dbus_error_free(&err);
  }
  dbus_connection_add_filter(conn, filter_cb, NULL, NULL);

  LOG("watching portal SettingChanged");
  while (dbus_connection_read_write_dispatch(conn, -1))
    ;
  return NULL;
}

/* --- init ---------------------------------------------------------------- */

__attribute__((constructor)) static void wechat_appearance_init(void) {
  atomic_store(&cached_scheme, -1);
  debug_enabled = env_flag("WECHAT_APPEARANCE_DEBUG", 0);
  follow_enabled = env_flag("WECHAT_APPEARANCE_FOLLOW", 1);
  live_enabled = env_flag("WECHAT_APPEARANCE_LIVE", 1);

  if (!follow_enabled) {
    LOG("disabled by WECHAT_APPEARANCE_FOLLOW=0");
    return;
  }

  void *apply_addr = find_apply_fn();
  if (!apply_addr) {
    LOG("appearance apply signature not found (wrong binary or WeChat update?)");
    return;
  }

  if (install_hook(apply_addr) != 0)
    return;

  if (live_enabled) {
    pthread_t th;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    if (pthread_create(&th, &attr, portal_thread, NULL) != 0)
      LOG("failed to start portal watcher");
    pthread_attr_destroy(&attr);
  }
}
