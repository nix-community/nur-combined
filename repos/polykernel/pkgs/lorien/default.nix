{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  godot3-headless,
  godot3-export-templates,
  libX11,
  libXcursor,
  libXinerama,
  libXrandr,
  libXrender,
}:

stdenv.mkDerivation rec {
  pname = "Lorien";
  version = "main";

  src = fetchFromGitHub {
    owner = "mbrlabs";
    repo = pname;
    rev = "30e37524ca3fe5998db0c22037384217a81b2e95";
    sha256 = "sha256-SpeOhayRGyQHJ7JAAh5Z5d6lMmjEapUDROWmjNVAa8s=";
  };

  nativeBuildInputs = [ godot3-headless godot3-export-templates ];

  buildInputs = [
    libX11
    libXcursor
    libXinerama
    libXrandr
    libXrender
  ];

  strictDeps = true;

  configurePhase = ''
    runHook preConfigure
    export HOME=$TMPDIR
    export BUILDDIR=$PWD/build
    mkdir -p "$HOME/.local/share/godot/templates"
    mkdir -p build
    ln -s "${godot3-export-templates}/share/godot/templates/${godot3-export-templates.version}.stable" "$HOME/.local/share/godot/templates/${godot3-export-templates.version}.stable"
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cd lorien
    godot3-headless --verbose --export "Linux/X11" $BUILDDIR/Lorien
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mv $BUILDDIR $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = " Infinite canvas drawing/whiteboarding app for Windows, Linux and macOS. Made with Godot.";
    homepage = "https://github.com/mbrlabs/Lorien";
    license = licenses.mit;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
    # See https://github.com/NixOS/nixpkgs/issues/86299
    broken = stdenv.hostPlatform.isDarwin;
  };
}
