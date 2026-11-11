# Nix-on-Droid app

Build with `nix build .#qb.nix-on-droid-app`. The release APK is under
`result/apk/release/` and is unsigned, like the other source-built Android apps.
Use the existing `fdroid-repo` workflow to sign and publish it.

The package pins nix-community/nix-on-droid-app and uses its Gradle lock file.
Java 11, Gradle 7.5, SDK 30, and the NDK versions follow upstream's flake.
Build tools 33.0.2 supply aapt2; 30.0.3 remains available for the Android plugin.

`mouse-tracking-1003.patch` is from
https://github.com/termux/termux-app/pull/5281 (commit
`b6a2615b0c8fda28363dc5578150fefc716d763f`). It makes DECSET 1003 behave
like 1002 for touch input, restoring taps through mosh when a tmux pane
requests all-motion mouse tracking. See
https://github.com/mobile-shell/mosh/issues/1364.

The build runs the terminal-emulator release unit tests, including the
patch's mouse tracking regression test. Touch behavior still needs testing
on an Android device.
