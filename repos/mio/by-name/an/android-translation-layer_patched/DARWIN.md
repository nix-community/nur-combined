# macOS support

This variant carries experimental Darwin patches on top of ATL's Linux backend.
Build with `nix build .#android-translation-layer_patched`. A successful build alone
is not an APK compatibility test; ART startup and an actual APK still need testing.
The runtime's Apple Silicon work is documented in
[`../../ar/art-standalone_patched/DARWIN-ARM64.md`](../../ar/art-standalone_patched/DARWIN-ARM64.md).

The Darwin backend uses GTK's macOS display backend. MediaCodec uses FFmpeg's
software decoder and GTK memory textures; Linux VA-API/DRM/DMA-BUF paths are
excluded. Vulkan surface creation requires a macOS Vulkan implementation exposing
`VK_MVK_macos_surface` and portability enumeration. The loader itself is not a
Vulkan implementation. OpenXR entrypoints are resolved dynamically and return
`XR_ERROR_RUNTIME_UNAVAILABLE` when the host loader or entrypoint is absent.

PCM `AudioTrack`/`AudioRecord` are backed by SDL2's CoreAudio driver. Playback is
queued and bounded, pause/flush are supported, stream and per-write volume are
applied, and playback-position notifications are delivered. Capture requires
`ATL_UGLY_ENABLE_MICROPHONE`; otherwise the constructor throws. SoundPool and
MediaPlayer keep using GTK media support.

Platform services use native macOS APIs:

- Notifications use `UNUserNotificationCenter`, including action buttons whose
  Android intents are serialized and replayed when the user taps them. Ongoing
  notifications are removed when the app tears down its manager.
- Media sessions publish to the system Now Playing centre (`MPRemoteCommandCenter`),
  with play/pause/toggle/next/previous/seek mapped back to the Android callback.
- Location uses Core Location behind `ATL_UGLY_ENABLE_LOCATION`, with authorization
  and Open/When-In-Use usage descriptions.
- Wallpaper setting writes the bitmap as PNG and applies it to every screen through
  `NSWorkspace`; the file is kept because macOS references it after the call.
- Vibration maps to `NSHapticFeedbackManager` trackpad haptics and honours cancel.

WebView is implemented with `WKWebView` behind `ATL_UGLY_ENABLE_WEBVIEW`, embedded
into the GTK widget hierarchy and clipped to the widget's visible bounds.
`android-asset://` loads APK assets, JavaScript evaluation and navigation callbacks
are wired to the Android side, and `evaluateJavascript` returns JSON results.
Without the variable, `WebView` keeps ATL's ordinary fallback View.

Input-method composition is implemented with `NSTextInputClient`: composing text,
commits, selection, surrounding-text deletion and hardware key events are forwarded
to the focused GTK editable.

The compatibility `memfd_create` uses an unlinked temporary file and honors
`MFD_CLOEXEC`; sealing and other Linux-only flags are unsupported. Darwin-specific
patches and compatibility headers are only added on Darwin. Native Android ELF
libraries are not made into macOS libraries by these patches.

## Validation

On aarch64-darwin the Nix build succeeds, including boot-image compilation, and
`android-translation-layer --help` exits successfully. The `darwin-audio` Meson test
runs in `checkPhase` and covers playback/capture queues, pause, flush, buffer
validation and caller-buffer ownership. A bounded NewPipe 0.29.1 smoke test reaches
`JVM launched successfully` and remains running; that does not establish UI or
playback correctness.

`darwin-host-test` (installed under `libexec/atl-tests`) exercises AppKit text input
and WKWebView HTML/JavaScript in a real window. It needs an Aqua session; it cannot
run from an SSH/background launchd session even though it builds and installs.
