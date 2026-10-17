{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../default.nix { inherit pkgs; }).pebrel,
}:
let
  overridden = package.overrideAttrs {
    version = "2.2.1";
    __intentionallyOverridingVersion = true;
  };
  darwinPackage =
    (import ../../default.nix {
      pkgs = import pkgs.path {
        localSystem = "aarch64-darwin";
        config = { };
        overlays = [ ];
      };
    }).pebrel;
in
assert
  package.meta.platforms == [
    "aarch64-darwin"
    "x86_64-linux"
  ];
assert builtins.elem "pebrel" (builtins.attrNames (import ../../default.nix { pkgs = null; }));
assert pkgs.lib.hasSuffix (
  if pkgs.stdenvNoCC.hostPlatform.isDarwin then
    "v2.2.1/Pebrel-v2.2.1-macos-arm64-preview.dmg"
  else
    "v2.2.1/Pebrel-v2.2.1-linux-x64-preview.tar.gz"
) overridden.src.url;
assert pkgs.lib.hasSuffix "v${package.version}/Pebrel-v${package.version}-macos-arm64-preview.dmg"
  darwinPackage.src.url;
assert darwinPackage.sourceRoot == "Pebrel.app";
assert darwinPackage.dontFixup;
pkgs.runCommand "pebrel-packaging-check"
  {
    nativeBuildInputs = pkgs.lib.optionals pkgs.stdenvNoCC.hostPlatform.isLinux [
      pkgs.binutils-unwrapped
      pkgs.glibc.bin
    ];
  }
  (
    ''
      export HOME="$TMPDIR/home"
      export XDG_CONFIG_HOME="$HOME/config"
      export XDG_CACHE_HOME="$HOME/cache"
      mkdir -p "$HOME"
      test -x ${package}/bin/pebrel
      test -x ${package}/bin/pebrel-hook
      ${package}/bin/pebrel --version > version.txt
      grep -F ${pkgs.lib.escapeShellArg package.version} version.txt
      ${package}/bin/pebrel --help > help.txt
      grep -F -- '--gpui' help.txt
      ${package}/bin/pebrel config init --config-file "$TMPDIR/pebrel.lua"
      test -s "$TMPDIR/pebrel.lua"
      ${package}/bin/pebrel config check --config-file "$TMPDIR/pebrel.lua"
      ${package}/bin/pebrel env > env.txt
      test -s env.txt
      printf '{"hook_event_name":"Stop","cwd":"%s"}\n' "$TMPDIR" | ${package}/bin/pebrel-hook
    ''
    + pkgs.lib.optionalString pkgs.stdenvNoCC.hostPlatform.isLinux ''
      grep -F "Exec=${package}/bin/pebrel" \
        ${package}/share/applications/io.github.kuddev.pebrel.desktop
      test -f ${package}/share/metainfo/io.github.kuddev.pebrel.metainfo.xml
      test -f ${package}/share/icons/hicolor/256x256/apps/io.github.kuddev.pebrel.png
      test -f ${package}/share/bash-completion/completions/pebrel
      test -f ${package}/share/fish/vendor_completions.d/pebrel.fish
      test -f ${package}/share/zsh/vendor-completions/_pebrel
      ! ldd ${package}/bin/.pebrel-wrapped | grep -F 'not found'
      readelf -d ${package}/bin/.pebrel-wrapped > dynamic.txt
      for library in libxcb wayland libglvnd vulkan-loader dbus libxkbcommon; do
        grep -F "$library" dynamic.txt
      done
    ''
    + pkgs.lib.optionalString pkgs.stdenvNoCC.hostPlatform.isDarwin ''
      test -f "${package}/Applications/Pebrel.app/Contents/Info.plist"
      test -x "${package}/Applications/Pebrel.app/Contents/MacOS/pebrel"
      test -x "${package}/Applications/Pebrel.app/Contents/MacOS/pebrel-hook"
      test "$(readlink ${package}/bin/pebrel)" = "${package}/Applications/Pebrel.app/Contents/MacOS/pebrel"
      test "$(readlink ${package}/bin/pebrel-hook)" = "${package}/Applications/Pebrel.app/Contents/MacOS/pebrel-hook"
    ''
    + ''
      touch "$out"
    ''
  )
