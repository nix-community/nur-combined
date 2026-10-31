/* SDL's CoreAudio driver provides queued PCM playback and microphone capture. */
#include "audio.h"
#include <SDL.h>
#include <limits.h>
#include <math.h>
#include <stdlib.h>
#include <stdatomic.h>
#include <string.h>
struct AtlAudio {
    SDL_AudioDeviceID device;
    int channels, capture;
    unsigned capacity;
    atomic_bool paused;
    unsigned used, read_offset;
    uint8_t *capture_data;
};
static _Atomic float stream_volume = 1.f;
int atl_audio_channels(int mask, int capture) {
    if (capture) return mask == 16 ? 1 : mask == 12 ? 2 : 0;
    return mask == 2 || mask == 4 ? 1 : mask == 12 ? 2 : 0;
}
int atl_audio_min_buffer(int rate, int channels, int encoding) {
    if (rate < 4000 || rate > 192000 || channels < 1 || channels > 2 || encoding != 2)
        return -2;
    return ((rate + 49) / 50) * channels * 2; /* 20 ms of PCM16. */
}
static void capture_audio(void *data, Uint8 *stream, int length) {
    AtlAudio *audio = data;
    unsigned count = (unsigned)length;
    if (count > audio->capacity) { stream += count-audio->capacity; count = audio->capacity; }
    unsigned drop = audio->used + count > audio->capacity ? audio->used + count-audio->capacity : 0;
    audio->read_offset = (audio->read_offset + drop) % audio->capacity;
    audio->used -= drop;
    unsigned offset = (audio->read_offset + audio->used) % audio->capacity;
    unsigned first = count < audio->capacity-offset ? count : audio->capacity-offset;
    memcpy(audio->capture_data + offset, stream, first);
    memcpy(audio->capture_data, stream + first, count-first);
    audio->used += count;
}
AtlAudio *atl_audio_open(int rate, int channels, int encoding, int bytes, int capture) {
    int minimum = atl_audio_min_buffer(rate, channels, encoding);
    if (minimum < 0 || bytes <= 0 || bytes % (channels * 2)) {
        SDL_SetError("Invalid PCM16 sample rate, channel mask or buffer size");
        return NULL;
    }
    static SDL_SpinLock init_lock;
    SDL_AtomicLock(&init_lock);
    int init_error = !(SDL_WasInit(SDL_INIT_AUDIO) & SDL_INIT_AUDIO) ? SDL_InitSubSystem(SDL_INIT_AUDIO) : 0;
    SDL_AtomicUnlock(&init_lock);
    if (init_error) return NULL;
    AtlAudio *audio = calloc(1, sizeof(*audio));
    if (!audio) { SDL_OutOfMemory(); return NULL; }
    SDL_AudioSpec spec = {.freq = rate, .format = AUDIO_S16LSB, .channels = channels, .samples = 512};
    audio->channels = channels;
    audio->capture = capture;
    audio->capacity = bytes > minimum * 4 ? (unsigned)bytes : (unsigned)minimum * 4;
    if (capture) {
        audio->capture_data = malloc(audio->capacity);
        if (!audio->capture_data) { free(audio); SDL_OutOfMemory(); return NULL; }
        spec.callback = capture_audio;
        spec.userdata = audio;
    }
    audio->device = SDL_OpenAudioDevice(NULL, capture, &spec, NULL, 0);
    if (!audio->device) { free(audio->capture_data); free(audio); return NULL; }
    atomic_init(&audio->paused, 1);
    return audio;
}
void atl_audio_close(AtlAudio *audio) {
    if (!audio) return;
    SDL_CloseAudioDevice(audio->device);
    free(audio->capture_data);
    free(audio);
}
void atl_audio_pause(AtlAudio *audio, int paused) {
    if (!audio) return;
    atomic_store(&audio->paused, !!paused);
    SDL_PauseAudioDevice(audio->device, !!paused);
}
void atl_audio_clear(AtlAudio *audio) {
    if (!audio) return;
    if (audio->capture) {
        SDL_LockAudioDevice(audio->device);
        audio->used = audio->read_offset = 0;
        SDL_UnlockAudioDevice(audio->device);
    } else SDL_ClearQueuedAudio(audio->device);
}
int atl_audio_pending(AtlAudio *audio) {
    return audio ? SDL_GetQueuedAudioSize(audio->device) / (audio->channels * 2) : 0;
}
void atl_audio_set_volume(float volume) {
    if (isfinite(volume)) atomic_store(&stream_volume, fminf(1.f, fmaxf(0.f, volume)));
}
const char *atl_audio_error(void) { return SDL_GetError(); }
int atl_audio_write(AtlAudio *audio, const int16_t *samples, int frames, float volume) {
    if (!audio || audio->capture || !samples || frames < 0 || !isfinite(volume)) return -2;
    if (!frames) return 0;
    unsigned frame_bytes = audio->channels * 2;
    /* Bounded queue: a paused track accepts available space without deadlocking. */
    unsigned pending = SDL_GetQueuedAudioSize(audio->device);
    while (pending >= audio->capacity && !atomic_load(&audio->paused)) {
        SDL_Delay(2);
        pending = SDL_GetQueuedAudioSize(audio->device);
    }
    unsigned available = pending < audio->capacity ? (audio->capacity - pending) / frame_bytes : 0;
    unsigned count = (unsigned)frames < available ? (unsigned)frames : available;
    if (!count) return 0;
    int16_t *copy = malloc(count * frame_bytes);
    if (!copy) return -1;
    float gain = fminf(1.f, fmaxf(0.f, volume)) * atomic_load(&stream_volume);
    for (unsigned i = 0; i < count * (unsigned)audio->channels; i++)
        copy[i] = (int16_t)(samples[i] * gain);
    int result = SDL_QueueAudio(audio->device, copy, count * frame_bytes);
    free(copy);
    return result ? -1 : (int)count;
}
int atl_audio_read(AtlAudio *audio, int16_t *samples, int frames) {
    if (!audio || !audio->capture || !samples || frames < 0 || frames > INT_MAX / (audio->channels * 2)) return -2;
    if (!frames || atomic_load(&audio->paused)) return 0;
    unsigned frame_bytes = audio->channels * 2;
    unsigned wanted = frames * frame_bytes;
    for (;;) {
        SDL_LockAudioDevice(audio->device);
        unsigned count = audio->used < wanted ? audio->used : wanted;
        if (count) {
            unsigned first = count < audio->capacity-audio->read_offset ? count : audio->capacity-audio->read_offset;
            memcpy(samples, audio->capture_data + audio->read_offset, first);
            memcpy((uint8_t *)samples + first, audio->capture_data, count-first);
            audio->read_offset = (audio->read_offset+count) % audio->capacity;
            audio->used -= count;
        }
        SDL_UnlockAudioDevice(audio->device);
        if (count) return count/frame_bytes;
        if (atomic_load(&audio->paused)) return 0;
        SDL_Delay(2);
    }
}
