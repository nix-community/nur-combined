# Moonlight OS display topology

Feature `0x0006`, version 1, carries the client's complete monitor set on the
encrypted control channel. The client sends it after feature negotiation and
again for every SDL display hotplug event. Helios stores only the newest valid
generation on the authenticated streaming session.

Message type: `0x6009`. All integers are little-endian.

```
u8 version = 1
u8 reserved = 0
u16 display_count (1..16)
u32 generation
display_count * {
  i32 x, y
  u32 width, height
  u32 refresh_millihz
  u32 scale_milli
  u16 physical_width_mm, physical_height_mm
  u16 flags (bit 0 primary, bit 1 HDR)
  u16 reserved = 0
}
```

Exactly one display must be primary. Signed positions describe one unified
desktop space, so a monitor left of the primary has a negative x coordinate.
The parser requires an exact message length, bounded dimensions/rates/scales,
known flags, and a strictly newer serial generation. A rejected update leaves
the prior topology intact.

This is deliberately topology state rather than a command. Platform providers
materialise it as virtual outputs, and video stream indices select those
outputs. The wire message can never name a host device, executable, or path.

Selene keeps display index 0 as the topology owner and starts one auxiliary
video session for every other client output. Keyboard, pointer, and touch input
belong to whichever display window has focus; Helios maps that session through
the selected virtual output's offset in the host desktop. Gamepads remain owned
by display index 0 because SDL controller events are process-global and would
otherwise be duplicated by every auxiliary process. A display hotplug sends a
new complete generation and reconciles the auxiliary session set.
