{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, godot-headless
, godot-export-templates
, libX11
, libXcursor
, libXinerama
, libXrandr
, libXrender
}:

stdenv.mkDerivation rec {
  pname = "Lorien";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "mbrlabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-x81Obana2BEGrYSoJHDdCkL6UaULfQGQ94tlrH5+kdY=";
  };

  nativeBuildInputs = [ godot-headless godot-export-templates ];

  buildInputs = [
    libX11
    libXcursor
    libXinerama
    libXrandr
    libXrender
  ];

  configurePhase = ''
    runHook preConfigure
    export HOME=$TMPDIR
    export BUILDDIR=$PWD/build
    mkdir -p "$HOME/.local/share/godot/templates"
    mkdir -p build
    ln -s "${godot-export-templates}/share/godot/templates/${godot-export-templates.version}.stable" "$HOME/.local/share/godot/templates/${godot-export-templates.version}.stable"
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cd lorien
    godot-headless --verbose --export "Linux/X11" $BUILDDIR/Lorien
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
