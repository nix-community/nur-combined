{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wl-uinput-proxy";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "pgaskin";
    repo = "wl-uinput-proxy";
    rev = "c24cdf3bc9d0b3b20f6f3b913999d87c333e40af";
    hash = "sha256-coJrAYecrRE25Ao+/NFTwuE6yRLlYCbloJ5WJJq/GJk=";
  };

  cargoHash = "sha256-Gtxz99gotvz9LI0mt3L7VUF4W/l6LPs6bvtta4Fs8CY=";

  meta = {
    description = "Wayland proxy implementing virtual keyboard/pointer using uinput";
    longDescription = ''
      Proxies an existing Wayland connection, implementing zwp_virtual_keyboard_v1
      and zwlr_virtual_pointer_v1 using uinput. Intended to make remote desktop
      implementations like wayvnc and RealVNC work correctly with compositors that
      have incomplete virtual input support (e.g. Smithay-based ones like niri),
      so compositor hotkeys, scrolling, and keymaps work. Requires /dev/uinput.
    '';
    homepage = "https://github.com/pgaskin/wl-uinput-proxy";
    license = lib.licenses.mit;
    mainProgram = "wl-uinput-proxy";
    platforms = lib.platforms.linux;
  };
})
