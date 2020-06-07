# Rhasspy - Voice assistant toolkit

These are packages/services to run [rhasspy](https://rhasspy.readthedocs.io/en/latest/).
Note that we do not package all possible combinations of rhasspy right now.
To use the package `nixpkgs-unstable` is required.

```
$ nix-shell -p nur.repos.mic92.rhasspy --command 'rhasspy'
```

The following setup has been tested for English.

- audio recording: PyAudio
- Wake word: Porcupine
- Speech to text: Kaldi
- Intent recognition: Fsticuffs
- Text to speech: Marytts with dfki-obadiah
- Audio playing: aplay
- Dialog management: Rhasspy
- Intent handling: Home-assistant

Also see the following profile.json: https://gist.github.com/Mic92/876da2963ed4f685cbbea8980a4a8a1a
