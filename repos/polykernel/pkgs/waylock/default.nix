{ stdenv
, lib
, fetchFromGitHub
, zig
, wayland
, xwayland
, wayland-protocols
, pkg-config
, scdoc
, libxkbcommon
, pam
}:

stdenv.mkDerivation rec {
  pname = "waylock";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ifreund";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-a9ioDR4crd14fzpPAUzVl5o/i4HSndZ0YI3iuufSsPI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig wayland scdoc pkg-config ];

  buildInputs = [
    wayland-protocols
    libxkbcommon
    pam
  ];

  dontConfigure = true;

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build -Drelease-safe -Dcpu=baseline -Dman-pages --prefix $out install
    runHook postInstall
  '';

  meta = with lib; {
    description = "A simple screenlocker for wayland compositors.";
    homepage = "https://github.com/ifreund/waylock";
    license = licenses.isc;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
