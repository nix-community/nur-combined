{
  lib,
  stdenv,
  sources,
  qq,
  qqRuntimeEnv,
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

    # LIBDIR is already substituted by the Makefile (LIBEXECDIR above); the rest
    # of what NixOS needs -- interactive bash for compgen, PATH, library paths,
    # EGL/ANGLE environment, the store QQ default, --doctor's /opt/QQ lookups and
    # the absolute Exec -- comes from the shared snippet.
${qqRuntimeEnv}

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

      The launcher keeps the upstream tools: `--doctor` checks the environment
      and whether the running QQ still matches the shims, `--version`, the
      QQ_WAYLAND_FIX_ANGLE backend switch (auto/vulkan/swiftshader/off) and the
      QQ_*_DISABLE troubleshooting switches. It logs to
      $XDG_RUNTIME_DIR/linuxqq-wayland-fix.log and preserves QQ crash records
      under ~/.cache/linuxqq-wayland-fix/crash. The installed script carries the
      NixOS adaptations upstream's packaging needs: the interactive bash, the
      PATH of helper tools, the pipewire/libva/opengl-driver library paths, the
      EGL/Vulkan hints and the store-side QQ paths. QQ_WAYLAND_FIX_QQ_ROOT
      overrides the installed QQ root used by diagnostics; newer launchers
      still prefer the executable and resources of a running QQ process.
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
