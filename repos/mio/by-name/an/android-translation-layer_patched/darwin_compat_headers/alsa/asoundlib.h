#ifndef ASOUNDLIB_H
#define ASOUNDLIB_H
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
typedef void* snd_pcm_t;
typedef void* snd_pcm_hw_params_t;
typedef void* snd_pcm_sw_params_t;
typedef void* snd_async_handler_t;
typedef unsigned long snd_pcm_uframes_t;
typedef long snd_pcm_sframes_t;
typedef int snd_pcm_format_t;
#define SND_PCM_STREAM_CAPTURE 0
#define SND_PCM_STREAM_PLAYBACK 1
#define SND_PCM_ACCESS_RW_INTERLEAVED 0
#define SND_PCM_FORMAT_S16_LE 0
#define SND_PCM_FORMAT_U8 1
#define SND_PCM_FORMAT_FLOAT_LE 2
#define SND_PCM_FORMAT_S32_LE 3
#define SND_PCM_FORMAT_S24_LE 4
static inline const char* snd_strerror(int err) { return ""; }
static inline int snd_pcm_open(snd_pcm_t **pcm, const char *name, int stream, int mode) { return -1; }
static inline int snd_pcm_hw_params_alloca(snd_pcm_hw_params_t **p) { return 0; }
static inline int snd_pcm_hw_params_set_buffer_size_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val) { return 0; }
static inline int snd_pcm_hw_params(snd_pcm_t *pcm, snd_pcm_hw_params_t *params) { return -1; }
static inline int snd_pcm_hw_params_get_period_size(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val, int *dir) { return -1; }
static inline int snd_pcm_sw_params_malloc(snd_pcm_sw_params_t **ptr) { return 0; }
static inline int snd_pcm_sw_params_current(snd_pcm_t *pcm, snd_pcm_sw_params_t *params) { return 0; }
static inline int snd_pcm_sw_params_set_start_threshold(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val) { return 0; }
static inline int snd_pcm_sw_params_set_avail_min(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val) { return 0; }
static inline int snd_pcm_sw_params(snd_pcm_t *pcm, snd_pcm_sw_params_t *params) { return 0; }
static inline int snd_pcm_hw_params_get_channels(const snd_pcm_hw_params_t *params, unsigned int *val) { return 0; }
static inline int snd_pcm_close(snd_pcm_t *pcm) { return 0; }
static inline int snd_pcm_start(snd_pcm_t *pcm) { return 0; }
static inline int snd_pcm_drain(snd_pcm_t *pcm) { return 0; }
static inline snd_pcm_sframes_t snd_pcm_readi(snd_pcm_t *pcm, void *buffer, snd_pcm_uframes_t size) { return 0; }
static inline int snd_pcm_recover(snd_pcm_t *pcm, int err, int silent) { return 0; }
static inline int snd_pcm_hw_params_get_buffer_time(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }
static inline int snd_pcm_hw_params_set_period_time_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }
static inline const char* snd_pcm_name(snd_pcm_t *pcm) { return ""; }
static inline const char* snd_pcm_state_name(int state) { return ""; }
static inline int snd_pcm_state(snd_pcm_t *pcm) { return 0; }
static inline int snd_pcm_hw_params_get_rate(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }
static inline int snd_pcm_hw_params_get_period_time(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }
static inline void* snd_async_handler_get_callback_private(snd_async_handler_t *handler) { return 0; }
static inline int snd_async_add_pcm_handler(snd_async_handler_t **handler, snd_pcm_t *pcm, void *callback, void *private_data) { return 0; }
static inline int snd_pcm_pause(snd_pcm_t *pcm, int enable) { return 0; }
static inline snd_pcm_sframes_t snd_pcm_writei(snd_pcm_t *pcm, const void *buffer, snd_pcm_uframes_t size) { return 0; }
static inline int snd_pcm_delay(snd_pcm_t *pcm, snd_pcm_sframes_t *delayp) { return 0; }
static inline int snd_pcm_hw_params_any(snd_pcm_t *pcm, snd_pcm_hw_params_t *params) { return 0; }
static inline int snd_pcm_hw_params_set_access(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, int access) { return 0; }
static inline int snd_pcm_hw_params_set_format(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, int format) { return 0; }
static inline int snd_pcm_hw_params_set_channels(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val) { return 0; }
static inline int snd_pcm_hw_params_set_rate_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }

typedef void* snd_mixer_t;
typedef void* snd_mixer_selem_id_t;
typedef void* snd_mixer_elem_t;
static inline int snd_mixer_open(snd_mixer_t **mixer, int mode) { return 0; }
static inline int snd_mixer_attach(snd_mixer_t *mixer, const char *name) { return 0; }
static inline int snd_mixer_selem_register(snd_mixer_t *mixer, void *options, void *classp) { return 0; }
static inline int snd_mixer_load(snd_mixer_t *mixer) { return 0; }
static inline int snd_mixer_selem_id_malloc(snd_mixer_selem_id_t **ptr) { return 0; }
static inline void snd_mixer_selem_id_set_index(snd_mixer_selem_id_t *obj, unsigned int val) {}
static inline void snd_mixer_selem_id_set_name(snd_mixer_selem_id_t *obj, const char *val) {}
static inline snd_mixer_elem_t* snd_mixer_find_selem(snd_mixer_t *mixer, const snd_mixer_selem_id_t *id) { return 0; }
static inline int snd_mixer_selem_get_playback_volume_range(snd_mixer_elem_t *elem, long *min, long *max) { return 0; }
static inline int snd_mixer_selem_set_playback_volume_all(snd_mixer_elem_t *elem, long value) { return 0; }
static inline int snd_mixer_close(snd_mixer_t *mixer) { return 0; }
static inline void snd_mixer_selem_id_free(snd_mixer_selem_id_t *obj) {}
#endif
