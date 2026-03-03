/*
 * Credits: https://blog.eh5.me/fix-ncm-flac-playing
 *          https://aur.archlinux.org/cgit/aur.git/tree/patch.c?h=netease-cloud-music
 *
 * I don't think this deserve any copyright, but in case you want a license:
 * -------------------------------------------------------------------
 *
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *                    Version 2, December 2004
 *
 * Copyright (C) 2022 Huang-Huang Bao <i@eh5.me>
 *
 * Everyone is permitted to copy and distribute verbatim or modified
 * copies of this license document, and changing it is allowed as long
 * as the name is changed.
 *
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 *
 *  0. You just DO WHAT THE FUCK YOU WANT TO.
 */

#define _GNU_SOURCE

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include <vlc/plugins/vlc_common.h>
#include <vlc/plugins/vlc_stream.h>
#include <vlc/vlc.h>

#define log_err(format, ...)                                                   \
  fprintf(stderr, "[n-c-m preload patch] " format, __VA_ARGS__)

static bool url_is_flac(const char *url) {
  const char *suffix = "\0";

  for (int i = (int)(strlen(url) - 1); i >= 0; --i) {
    if (url[i] == '.') {
      suffix = url + i + 1;
      break;
    }
  }

  return strcasecmp(suffix, "flac") == 0;
}

VLC_API int vlc_stream_vaControl(stream_t *s, int query, va_list args) {
  static typeof(vlc_stream_vaControl) *orig_func;

  if (orig_func == NULL) {
    orig_func = dlsym(RTLD_NEXT, __func__);
    if (orig_func == NULL)
      goto fatal;
    if (orig_func == (void *)vlc_stream_Control)
      goto fatal;
  }

  if (query == STREAM_GET_CONTENT_TYPE && url_is_flac(s->psz_url)) {
    // duplicated string will be freed by consumer
    *va_arg(args, char **) = strdup("audio/flac");
    return VLC_SUCCESS;
  } else {
    return orig_func(s, query, args);
  }

fatal:
  log_err(
      "failed to get original function address of %s, got %p, preload func: %p",
      __func__, orig_func, vlc_stream_vaControl);
  exit(1);
}
