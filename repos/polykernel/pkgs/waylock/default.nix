{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, libxkbcommon
, pam
}:

rustPlatform.buildRustPackage rec {
  pname = "waylock";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "ifreund";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Z3yLfReoWeA7mHkUSAnMR+ibTi7bpxOw7uj7eY4immc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxkbcommon
    pam
  ];

  cargoSha256 = "sha256-R2QEGITU+YAatdMzhl3IlMv/Qf2egl7fNWknFE4E+u4=";

  meta = with lib; {
    description = "A simple screenlocker for wayland compositors.";
    homepage = "https://github.com/ifreund/waylock";
    license = licenses.mit;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
