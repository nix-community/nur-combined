// 2020-04-10:
// Latest tetrio update is causing OOMs in the encoder,
// this increases the allocated memory from 16MiB to 64MiB
var OggVorbisEncoderConfig = { TOTAL_MEMORY: 64 * 1024**2 };
