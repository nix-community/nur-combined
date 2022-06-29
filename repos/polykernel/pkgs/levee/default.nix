{ stdenv
, lib
, fetchFromSourcehut
, zig
, wayland
, pixman
, wayland-protocols
, pkg-config
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
    rev = "c0f0e5a8160064e8dfbf98b7895a4dab9a03ffd9";
    sha256 = "sha256-h1nSShx60gUw4JBuFBsrgsg6Hfu7hp/voYxgXOUWE/U=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig wayland pkg-config ];

  buildInputs = [
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

  installPhase = ''
    runHook preInstall
    zig build -Drelease-safe -Dcpu=baseline --prefix $out install
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
