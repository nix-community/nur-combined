# ALVR

This package builds ALVR from upstream's development branch. Use a compatible development client on the headset.

## USB connections

The package bundles Android tools with a static wrapper that clears `LD_LIBRARY_PATH` before starting ADB. SteamVR supplies its own library paths, which can load libraries incompatible with ADB's dependencies.

Native USB setup selects this wrapper directly. Upstream's usual ADB lookup prefers the host's `PATH`, which can bypass the wrapper and leave ALVR disconnected even when ADB detects the headset from a terminal. Keep the native USB selection and wrapper isolation when updating the package.

The patch applies only to native USB setup. The ALVR launcher's handling of downloaded releases keeps upstream's ADB selection and download behavior.

## Wireless connections

The Connections page has an **Enable wireless** toggle beside the wired control. It is enabled by default and saved with the session settings.

Turning it off stops discovery and new Wi-Fi connection attempts, including attempts to saved manual IP addresses. USB connections remain available, saved devices are retained, and an existing wireless stream can continue until it ends. Turning it back on resumes wireless connections with the existing discovery preferences.
