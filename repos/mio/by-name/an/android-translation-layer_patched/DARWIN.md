# macOS support

This variant carries experimental Darwin patches on top of ATL's Linux backend.
Build with `nix build .#android-translation-layer_patched`. A successful build alone
is not an APK compatibility test; ART startup and an actual APK still need testing.
The runtime's Apple Silicon work is documented in
[`../../ar/art-standalone_patched/DARWIN-ARM64.md`](../../ar/art-standalone_patched/DARWIN-ARM64.md).

The Darwin backend uses GTK's macOS display backend. MediaCodec uses FFmpeg's
software decoder and GTK memory textures; Linux VA-API/DRM/DMA-BUF paths are
excluded. Vulkan SurfaceViews get a dedicated `CAMetalLayer`-backed `NSView` placed
over the widget, because the ICDs only accept a layer that is a `CAMetalLayer` and
GTK's window content view is not one. Surface creation prefers `VK_EXT_metal_surface`
and falls back to the deprecated `VK_MVK_macos_surface`. Instance extensions are
probed with `vkEnumerateInstanceExtensionProperties`, so only extensions the ICD
advertises (surface extensions and portability enumeration, which also sets
`VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR`) are requested and
`VK_KHR_android_surface` never reaches the host loader. The loader itself is not a
Vulkan implementation. OpenXR entrypoints are resolved dynamically and return
`XR_ERROR_RUNTIME_UNAVAILABLE` when the host loader or entrypoint is absent.

PCM `AudioTrack`/`AudioRecord` are backed by SDL2's CoreAudio driver. Playback is
queued and bounded, pause/flush/stop are supported (`stop` also resets the playback
head position), stream and per-write volume are applied, and playback-position
notifications are delivered. A `read` on a stopped record waits briefly instead of
returning immediately. Capture requires `ATL_UGLY_ENABLE_MICROPHONE`; otherwise the
constructor throws. SoundPool and MediaPlayer keep using GTK media support.

Platform services use native macOS APIs:

- Notifications use `UNUserNotificationCenter`, including action buttons whose
  Android intents are serialized and replayed when the user taps them. A small icon
  that ATL resolved to a file path is attached from a temporary copy. Ongoing
  notifications are removed when the app tears down its manager.
- Media sessions publish to the system Now Playing centre (`MPRemoteCommandCenter`),
  with play/pause/toggle/next/previous/seek mapped back to the Android callback.
  Title/artist/artwork are dropped when an update no longer carries them; artwork is
  fetched for `file://` and `http(s)://` URIs (`content://` needs the app's resolver).
- Location uses Core Location behind `ATL_UGLY_ENABLE_LOCATION`, with authorization
  and Open/When-In-Use usage descriptions.
- Wallpaper setting writes the bitmap as PNG and applies it to every screen through
  `NSWorkspace`; the single backing file is rewritten in place because macOS keeps
  referencing it after the call, and older copies are removed.
- Vibration maps to `NSHapticFeedbackManager` trackpad haptics and honours cancel.

WebView is implemented with `WKWebView` behind `ATL_UGLY_ENABLE_WEBVIEW`, embedded
into the GTK widget hierarchy and clipped to the widget's visible bounds.
`android-asset://` loads APK assets, JavaScript evaluation and navigation callbacks
are wired to the Android side, and `evaluateJavascript` returns JSON results.
Without the variable, `WebView` keeps ATL's ordinary fallback View.

Input-method composition is implemented with `NSTextInputClient`: composing text,
commits, selection, surrounding-text deletion and hardware key events are forwarded
to the focused GTK editable.

The compatibility `memfd_create` uses an unlinked temporary file opened with
`O_CLOEXEC`, so `MFD_CLOEXEC` is honoured without a fork/exec race; sealing and other
Linux-only flags are unsupported. Darwin-specific patches and compatibility headers
are only added on Darwin. Native Android ELF libraries are not made into macOS
libraries by these patches.

## Validation

On aarch64-darwin the Nix build succeeds, including boot-image compilation, and
`android-translation-layer --help` exits successfully. The `darwin-audio` Meson test
runs in `checkPhase` and covers playback/capture queues, pause, flush, buffer
validation and caller-buffer ownership. Vulkan SurfaceView creation is not covered by
these checks: it needs an installed Vulkan implementation (MoltenVK or KosmicKrisp)
and an app that uses `SurfaceView`. A bounded NewPipe 0.29.1 smoke test reaches
`JVM launched successfully` and remains running; that does not establish UI or
playback correctness.

`darwin-host-test` (installed under `libexec/atl-tests`) exercises AppKit text input
and WKWebView HTML/JavaScript in a real window. It needs an Aqua session; it cannot
run from an SSH/background launchd session even though it builds and installs.

## Native looper

AOSP's C++ `android::Looper` is not part of this build, so `libandroid` imported
`android::Looper::prepare`, `getForThread`, `addFd`, `removeFd`, `wake`, `isPolling`,
`pollOnce`, `pollAll` and `RefBase::incStrong`/`decStrong` without any provider. The
first call (`ALooper_prepare` in `prepare_main_looper`) jumped through a lazy symbol
stub to address 0 and killed the process.

`android-translation-layer-darwin-looper.patch` backs the public looper API with glib
instead: each thread gets an opaque looper handle, file-descriptor callbacks become
`GSource`s on the default main context, `ALooper_wake` wakes that context, and the
polling entry points sleep for their timeout and report `ALOOPER_POLL_TIMEOUT`. The
Linux build keeps using the AOSP C++ implementation unchanged.

With this and the ART monitor fixes, a NewPipe 0.29.3 run gets past `loadLibrary`,
`prepare_main_looper` and GTK initialisation. It then crashes in JIT-compiled code
(low-address fault) instead of hanging; see
`by-name/ar/art-standalone_patched/DARWIN-ARM64.md` for the monitor analysis and the
remaining fault.
