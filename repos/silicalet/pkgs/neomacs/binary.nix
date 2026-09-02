{
  lib,
  autoPatchelfHook,
  fetchurl,
  fontconfig,
  gst_all_1,
  lcms2,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  makeWrapper,
  ncurses,
  stdenv,
  vulkan-loader,
  wayland,
  zlib,
}:

let
  pname = "neomacs-bin";
  sources = {
    x86_64-linux = import ./sources/x86_64-linux.nix;
    aarch64-linux = import ./sources/aarch64-linux.nix;
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "neomacs-bin is unsupported on ${stdenv.hostPlatform.system}");
  inherit (source) version;
  src = fetchurl {
    inherit (source) url hash;
  };
  runtimeLibraries = [
    fontconfig
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    lcms2
    libGL
    libx11
    libxcb
    libxcursor
    libxi
    libxkbcommon
    ncurses
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
    zlib
  ];
  gstreamerPlugins = with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
in
stdenv.mkDerivation {
  inherit pname version src;
  inherit (source) sourceRoot;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = runtimeLibraries;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share"

    # Older releases use either an installed x86_64 tree (bin/ + share/)
    # or a flat aarch64 tree.  Since 0.0.16, both targets use the installed
    # tree and keep the preloaded dump in libexec/neomacs/<version>/<target>.
    if [[ -d bin ]]; then
      cp -r bin/. "$out/bin/"
      cp -r share/neomacs "$out/share/neomacs"
      if [[ -d libexec ]]; then
        cp -r libexec "$out/"
      fi
    else
      install -Dm755 neomacs neomacsclient -t "$out/bin"
      install -Dm444 neomacs.pdump "$out/bin/neomacs.pdump"
      mkdir -p "$out/share/neomacs"
      cp -r etc lisp "$out/share/neomacs/"
    fi

    install -Dm444 "$out/share/neomacs/etc/emacs.desktop" \
      "$out/share/applications/neomacs.desktop"
    substituteInPlace "$out/share/applications/neomacs.desktop" \
      --replace-fail 'Name=Emacs' 'Name=NEO Emacs' \
      --replace-fail 'Exec=emacs %F' 'Exec=neomacs %F' \
      --replace-fail 'Icon=emacs' 'Icon=neomacs' \
      --replace-fail 'StartupWMClass=Emacs' 'StartupWMClass=neomacs'

    for icon in "$out"/share/neomacs/etc/images/icons/hicolor/*/apps/emacs.png; do
      size="$(basename "$(dirname "$(dirname "$icon")")")"
      install -Dm444 "$icon" \
        "$out/share/icons/hicolor/$size/apps/neomacs.png"
    done
    install -Dm444 \
      "$out/share/neomacs/etc/images/icons/hicolor/scalable/apps/emacs.svg" \
      "$out/share/icons/hicolor/scalable/apps/neomacs.svg"

    runHook postInstall
  '';

  postFixup = ''
    for program in neomacs bootstrap-neomacs neomacs-temacs; do
      if [[ -x "$out/bin/$program" ]]; then
        wrapProgram "$out/bin/$program" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}" \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : \
            "${lib.makeSearchPath "lib/gstreamer-1.0" gstreamerPlugins}"
      fi
    done

    # The old flat layout keeps the dump beside the executable.  Newer
    # releases place it in libexec, where the runtime resolver expects it.
    if [[ -f "$out/bin/neomacs.pdump" ]]; then
      ln -s neomacs.pdump "$out/bin/.neomacs-wrapped.pdump"
    fi
  '';

  meta = {
    description = "GPU-powered Emacs fork with a Rust core and display engine";
    homepage = "https://github.com/eval-exec/neomacs";
    changelog = "https://github.com/eval-exec/neomacs/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "neomacs";
    platforms = builtins.attrNames sources;
  };
}
