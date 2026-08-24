# Moonlight OS camera uplink

The camera is a dedicated authenticated real-time uplink. It is not USB/IP: the client
captures V4L2 MJPEG and sends the compressed frames over UDP, which avoids forwarding the
camera's raw USB traffic.

## Negotiation and transport

- Host RTSP flag: `LI_FF_CAMERA_UPLINK` (`0x08`)
- Client feature: `ML_FEATURE_CAMERA` (`0x0005`, version 1)
- RTSP setup stream: `streamid=camera/0/0`
- Default UDP port: 13, passed through the normal port-offset mapping
- Maximum decoded MJPEG frame: 4 MiB
- Fragment payload: at most 1050 bytes, keeping the complete datagram MTU-safe

The 36-byte public datagram header contains `MLCA`, version 1, total length, the session's
control connect value, an unsigned 64-bit sequence, and a 16-byte AES-GCM tag. The sequence
is the first eight bytes of the nonce; the last two bytes are `CA`. The encrypted fragment
header contains the frame id, client timestamp, dimensions, MJPEG format id, fragment index
and count, complete frame length, and deterministic byte offset.

Every fragment is authenticated before parsing. The receiver requires canonical contiguous
fragments, rejects duplicate sequence numbers and duplicate indexes, bounds allocation, and
drops an incomplete frame after 500 ms. A lost fragment therefore affects only its frame.

## Platform endpoints

The Selene client probes V4L2 capture devices and requests 1280x720 MJPEG. Helios publishes
complete frames to a V4L2 video-output device such as `v4l2loopback`. Capability advertisement
is disabled when no virtual-camera endpoint is available.

For deterministic testing without camera hardware, point Selene at one valid JPEG with
`MOONLIGHT_CAMERA_TEST_MJPEG`. On Linux, set `HELIOS_CAMERA_TEST_OUTPUT` to a path that does
not exist; Helios creates it without following symlinks and appends records consisting of a
12-byte big-endian frame header (length, width, height, timestamp) followed by the JPEG.

Windows uses the Windows 11 Media Foundation virtual-camera path. Its custom media source is
an installed user-mode COM component; no DirectShow or signed kernel camera driver is used.
