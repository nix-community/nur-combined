{
  stdenv,
  lib,
  fetchFromSourcehut,
  pkg-config,
  zig,
  pixman,
  wayland,
  wayland-protocols,
  fcft,
  pulseaudio,
  udev,
}:
stdenv.mkDerivation rec {
  pname = "levee";
  version = "0.1.2";

  src = fetchFromSourcehut {
    owner = "~andreafeletto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Y0qEIIrEy5JAYdTts+vpoZG4yEFe9HPMKP/r+6CuE3M=";
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
    maintainers = [maintainers.polykernel];
    platforms = platforms.linux;
  };
}
