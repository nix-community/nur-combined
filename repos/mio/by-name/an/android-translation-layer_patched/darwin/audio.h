#ifndef ATL_DARWIN_AUDIO_H
#define ATL_DARWIN_AUDIO_H
#include <stdint.h>
typedef struct AtlAudio AtlAudio;
int atl_audio_channels(int mask, int capture);
int atl_audio_min_buffer(int rate, int channels, int encoding);
AtlAudio *atl_audio_open(int rate, int channels, int encoding, int bytes, int capture);
void atl_audio_close(AtlAudio *audio);
void atl_audio_pause(AtlAudio *audio, int paused);
void atl_audio_clear(AtlAudio *audio);
int atl_audio_write(AtlAudio *audio, const int16_t *samples, int frames, float volume);
int atl_audio_read(AtlAudio *audio, int16_t *samples, int frames);
int atl_audio_pending(AtlAudio *audio);
void atl_audio_set_volume(float volume);
const char *atl_audio_error(void);
#endif
