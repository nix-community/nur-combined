#include "../audio.h"
#include <SDL.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
int main(void) {
    assert(atl_audio_channels(4,0) == 1 && atl_audio_channels(12,0) == 2);
    assert(atl_audio_channels(16,1) == 1 && atl_audio_channels(12,1) == 2);
    assert(atl_audio_channels(99,0) == 0);
    assert(atl_audio_min_buffer(48000,2,2) == 3840);
    assert(atl_audio_min_buffer(0,2,2) == -2 && atl_audio_min_buffer(48000,3,2) == -2);
    assert(atl_audio_min_buffer(48000,2,4) == -2);
    assert(!atl_audio_open(48000,2,2,3,0));
    AtlAudio *output = atl_audio_open(48000,2,2,4096,0);
    if (!output) { fprintf(stderr,"%s\n",atl_audio_error()); return 1; }
    int16_t samples[2048];
    for (int i=0;i<2048;i++) samples[i] = i-1024;
    int16_t original[2048]; memcpy(original,samples,sizeof(samples));
    assert(atl_audio_write(output,samples,1024,.5f) == 1024);
    assert(!memcmp(samples,original,sizeof(samples))); /* Never scale the caller's buffer. */
    assert(atl_audio_pending(output) == 1024);
    assert(atl_audio_write(output,samples,1,NAN) == -2);
    SDL_Delay(30); assert(atl_audio_pending(output) == 1024); /* Paused. */
    atl_audio_pause(output,0);
    Uint32 deadline = SDL_GetTicks()+1000;
    while (atl_audio_pending(output) && SDL_GetTicks() < deadline) SDL_Delay(5);
    assert(atl_audio_pending(output) == 0);
    atl_audio_pause(output,1);
    assert(atl_audio_write(output,samples,1024,1) == 1024);
    atl_audio_clear(output); assert(atl_audio_pending(output) == 0);
    /* Full paused queues return without blocking or growing indefinitely. */
    for(int i=0;i<100;i++) atl_audio_write(output,samples,1024,1);
    assert(atl_audio_write(output,samples,1024,1) == 0);
    atl_audio_close(output);
    AtlAudio *input = atl_audio_open(48000,1,2,4096,1);
    assert(input);
    assert(atl_audio_read(input,samples,512) == 0);
    atl_audio_pause(input,0);
    memset(samples,0x42,sizeof(samples));
    int count = atl_audio_read(input,samples,512); assert(count > 0 && count <=512);
    for (int i=0;i<count;i++) assert(samples[i] == 0); /* SDL dummy capture. */
    atl_audio_pause(input,1); atl_audio_clear(input);
    assert(atl_audio_read(input,samples,512) == 0);
    atl_audio_close(input); atl_audio_close(NULL);
    puts("Darwin PCM playback/capture, pause, flush, bounds and ownership passed");
}
