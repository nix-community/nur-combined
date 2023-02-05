{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  zig,
  wayland,
  wayland-protocols,
  scdoc,
  libxkbcommon,
  pam,
}:

stdenv.mkDerivation rec {
  pname = "waylock";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "ifreund";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-QMp7LbkH2TCVOqmIBq9j/9LHRFDna7CQQnNkdoNKqe8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config zig scdoc ];

  buildInputs = [
    wayland.dev
    wayland-protocols
    libxkbcommon
    pam
  ];

  dontConfigure = true;

  preBuild = ''
    export HOME=$TMPDIR
  '';

  buildPhase = ''
    runHook preBuild
    zig build -Drelease-safe -Dcpu=baseline -Dman-pages --prefix $out install
    runHook postBuild
  '';

  meta = with lib; {
    description = "A simple screenlocker for wayland compositors.";
    homepage = "https://github.com/ifreund/waylock";
    license = licenses.isc;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
