{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "0.14.2.1";

  src = fetchFromGitHub {
    owner = "tinybeachthor";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-gNMqDX2AXbIpy2dmeuaG8LlWVnUX8KetHId49x2/QrU=";
  };

  cargoSha256 = "sha256-akS5TxVQR2Jts+nq+YhzaGic/2T2KwNJQ8YPs6zfu8M=";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Very resource-friendly and feature-rich replacement for i3status";
    homepage = "https://github.com/greshake/i3status-rust";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
