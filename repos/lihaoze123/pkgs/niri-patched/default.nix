{ pkgs, agentInput ? true }:
let
  pins = pkgs.lib.importJSON ../codex-desktop/sources.json;
  niriSource = pkgs.fetchFromGitHub { inherit (pins.niri) owner repo rev hash; } // { inherit (pins.niri) rev; };
in

pkgs.niri.overrideAttrs (old: {
  version = "26.04-unstable-2026-10-13";
  src = niriSource;
  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    src = niriSource;
    hash = "sha256-WxGAqLxK7uTkUUYhsoH2B2QGh6dq1z/bvif57Yn1L8w=";
  };
  buildInputs = old.buildInputs ++ [ pkgs.cairo ];
  env = (old.env or { }) // {
    NIRI_BUILD_COMMIT = niriSource.rev;
    NIRI_BUILD_VERSION_STRING = "26.04-unstable-2026-10-13";
  };
  # Smithay #2213: keep input-method keyboard grabs in sync when wtype changes
  # the seat keymap. Until upstream merges it, patch the vendored git dependency.
  postPatch = (old.postPatch or "") + ''
    smithayVendor=( "$cargoDepsCopy"/source-*/smithay-0.7.0 )
    test "''${#smithayVendor[@]}" -eq 1
    patch -p1 -d "''${smithayVendor[0]}" < ${./patches/smithay-input-method-keymap.patch}
  '';
  patches = (old.patches or [ ])
    ++ [ ./patches/niri-ipc-tiled-window-position.patch ]
    ++ pkgs.lib.optional agentInput ./patches/niri-agent-input.patch;
})
