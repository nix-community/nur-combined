{
  lib,
  stdenv,
  bashInteractive,
  sources,
  qq,
  waylandFix,
}:

let
  # nvfetcher tracks the branch tip (upstream tags lag behind it) and exposes
  # the UTC commit date.
  version = "0-unstable-${sources.qq-wayland-fix.date}";
in
stdenv.mkDerivation {
  pname = "linuxqq-wayland-fix-launcher";
  inherit version;

  src = sources.qq-wayland-fix.src;

  buildPhase = ''
    runHook preBuild
    make linuxqq-wayland-fix LIBEXECDIR=${waylandFix}/lib VERSION=${version}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Upstream's launcher is a distro bash script: it calls compgen, which
    # nixpkgs' non-interactive bash build does not compile in, so keep the
    # interactive build as the interpreter.
    #
    # The upstream launcher only looks for a `linuxqq` command or /opt/QQ/qq;
    # neither exists for the nixpkgs `qq` install. Seed its documented
    # QQ_WAYLAND_FIX_QQ override with the packaged QQ wrapper, which the user
    # can still replace by exporting the variable.
    substituteInPlace linuxqq-wayland-fix \
      --replace-fail '#!/bin/bash' "#!${lib.getExe bashInteractive}" \
      --replace-fail 'set -u' 'set -u
: "''${QQ_WAYLAND_FIX_QQ:=${qq}/bin/qq}"'

    install -Dm755 linuxqq-wayland-fix $out/bin/linuxqq-wayland-fix
    install -Dm644 linuxqq-wayland-fix.desktop $out/share/applications/linuxqq-wayland-fix.desktop
    install -Dm644 README.md $out/share/doc/linuxqq-wayland-fix/README.md
    for doc in docs/*.md; do
      install -Dm644 "$doc" "$out/share/doc/linuxqq-wayland-fix/$doc"
    done
    install -Dm644 LICENSE $out/share/licenses/linuxqq-wayland-fix/LICENSE

    # The desktop entry ships Icon=qq, but icons are looked up through the
    # session's XDG_DATA_DIRS, which never contains a dependency's share tree;
    # expose QQ's icons from this output so a standalone install shows them.
    ln -s ${qq}/share/icons $out/share/icons

    runHook postInstall
  '';

  meta = {
    description = "Standalone linuxqq-wayland-fix launcher and desktop entry for a separately installed QQ";
    longDescription = ''
      Ships the upstream launcher and desktop entry ("QQ（Wayland修复版）") to
      inject the fix into a separately installed QQ -- the `qq` package, a
      distro linuxqq or an AppImage -- instead of replacing QQ's own launcher
      as the `qq-wayland-fix` package does. QQ is located through the
      documented QQ_WAYLAND_FIX_QQ override (seeded with the packaged `qq`
      wrapper, still overridable), then a `linuxqq` command in PATH, then
      /opt/QQ/qq; the four LD_PRELOAD shims are shared with `qq-wayland-fix`.
      The desktop entry is installed byte-identical to upstream and the launcher
      only swaps its shebang for the interactive bash that provides compgen and
      seeds the QQ default.

      The launcher keeps the upstream tools: `--doctor` checks the environment
      and whether the running QQ still matches the shims, `--version`, the
      QQ_WAYLAND_FIX_ANGLE backend switch (auto/vulkan/swiftshader/off) and the
      QQ_*_DISABLE troubleshooting switches. It logs to
      $XDG_RUNTIME_DIR/linuxqq-wayland-fix.log and preserves QQ crash records
      under ~/.cache/linuxqq-wayland-fix/crash.
    '';
    homepage = "https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix";
    license = lib.licenses.mit;
    mainProgram = "linuxqq-wayland-fix";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
