# Yamaha SMAF player

`ma7.patch` adds format-3 event decoding and basic MA-7 FM voice decoding to
upstream revision 627f7ad8583ce34c5fec0269ef9778167af080d6.

MA-7 uses the lower seven bits for the event class/channel and bit 7 to select
channels 16–31. F0/FF system events retain their Mobile encoding. Decode the
status before dispatch, and keep running velocity separately for all 32
channels. The track channel allocation must fit all 32 channels in the player's
128 slots.

Basic MA-7 FM definitions (`43 79 08 7f 21`, voice type 0) have three global
bytes and ten bytes per operator. The first seven operator bytes map to VM35;
the additional MA-7 controls are not implemented. Advanced filtered FM and
sampled voices still use the existing approximate instrument fallback. MA-7
effects and sample banks in setup exclusives are not decoded by this patch.

CTest compares generated MA-7 and Mobile scores, including both channel banks,
independent running velocities, controllers, program changes, pitch bend, system
events, and multi-byte timing. It also checks basic 2/4-operator FM definitions
and truncated/unsupported definitions. No user ringtone data is included.

The twelve user files in `/tmp/tmp.McLe5GlYyl-vacu-nts-gokian` reproduced seven
silent renders and five initialization failures before this patch. Use those
files for additional playback checks when they are available. All twelve now
render non-silent stereo WAVs successfully. Generated tests do not establish
fidelity to Yamaha hardware.
