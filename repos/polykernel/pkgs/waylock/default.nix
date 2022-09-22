{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, zig
, wayland
, wayland-protocols
, scdoc
, libxkbcommon
, pam
}:

stdenv.mkDerivation rec {
  pname = "waylock";
  # Note: the ext_session_lock_manager_v1 protocol is not yet supported by released versions of Sway and river.
  # https://github.com/ifreund/waylock/blob/master/PACKAGING.md
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "ifreund";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-bV2wHuLxRP478Lap8cB3pYI/98DlxknYFgqgG4S44gY=";
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

  installPhase = ''
    runHook preInstall
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
