{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  qt6,
  libpng,
  libGL,
  zlib,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qpxtool";
  version = "0.8.1-pl8";

  src = fetchFromGitHub {
    owner = "speed47";
    repo = "qpxtool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-baljQxske1sUeEERg2xKwz4LtrEuK2bgvaqod762hhc=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    qt6.wrapQtAppsHook
    qt6.qtbase
    qt6.qttools
    libpng
  ];

  buildInputs = [
    libpng
    libGL
    zlib
    qt6.qtbase
  ];

  strictDeps = true;
  __structuredAttrs = true;

  postPatch = ''
    # qmake reports qtbase's own directories, but lrelease lives in qttools.
    substituteInPlace configure \
      --replace-fail '"$qt_bindir/lrelease"' '"$(command -v lrelease)"'
    # Plugin discovery is hardcoded to /usr/lib*, which Nix cannot satisfy.
    substituteInPlace lib/qpxscan/include/qpx_scan.h \
      --replace-fail "/usr/lib/qpxtool" "$out/lib/qpxtool"
    # The store cannot hold setuid binaries; upstream installs three tools as 4755.
    for mf in console/{cdvdcontrol,f1tattoo,qscan}/Makefile; do
      substituteInPlace "$mf" --replace-fail 'install -m 4755' 'install -m 755'
    done
  '';

  # The hand-written configure rejects the standard --*dir= flags injected for
  # multiple outputs; let stdenv's moveToOutput hooks split the tree instead.
  setOutputFlags = false;

  # Upstream defaults to lib64 on x86_64; move-lib64.sh relocates it only after
  # shrink-RPATH has stripped $out/lib, which would leave libqpx* unresolvable.
  configureFlags = [ "--libdir=${placeholder "out"}/lib" ];

  enableParallelBuilding = true;

  # Only the GUI uses Qt; leave the CLI tools unwrapped.
  dontWrapQtApps = true;
  # The GUI spawns qscan/cdvdcontrol by name via QProcess, so it needs its peers on PATH.
  postFixup = ''
    wrapQtApp $out/bin/qpxtool --prefix PATH : $out/bin
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CD/DVD/BD media quality checker and drive control tools";
    homepage = "https://github.com/speed47/qpxtool";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "qpxtool";
    platforms = lib.platforms.linux;
  };
})
