{ stdenv
, lib
, fetchFromSourcehut
, pkg-config
, zig
, pixman
, wayland
, wayland-protocols
, fcft
, pulseaudio
, udev
}:

stdenv.mkDerivation rec {
  pname = "levee";
  version = "main";

  src = fetchFromSourcehut {
    owner = "~andreafeletto";
    repo = pname;
    rev = "a28f39e9f7014e1cea6976522693c0ec740d094f";
    sha256 = "sha256-iTUvlYF6Z6BbTNc3aekWj/NXkHVJPlGvbw9X3/hNVww=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config zig ];

  buildInputs = [
    wayland.dev
    wayland-protocols
    pixman
    fcft
    pulseaudio
    udev
  ];

  dontConfigure = true;

  preBuild = ''
    export HOME=$TMPDIR
  '';

  buildPhase = ''
    runHook preBuild
    zig build -Drelease-safe -Dcpu=baseline --prefix $out install
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  meta = with lib; {
    description = "Statusbar for the river wayland compositor.";
    homepage = "https://git.sr.ht/~andreafeletto/levee";
    license = licenses.mit;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
