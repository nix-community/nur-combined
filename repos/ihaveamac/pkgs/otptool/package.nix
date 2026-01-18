{
  lib,
  stdenv,
  fetchFromGitHub,
  libgcrypt,
  openssl,
}:

stdenv.mkDerivation rec {
  pname = "otptool";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "SciresM";
    repo = pname;
    rev = "5ed22856538f8a3352482c24268ba42f70a2193d";
    hash = "sha256-icFUWtR8loe9lNwHFCMOJOx/fQyt/YlAW9nEISi24gE=";
  };

  buildInputs = [
    libgcrypt
    openssl
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1
    cp otptool${stdenv.hostPlatform.extensions.executable} $out/bin
    cp otptool.1 $out/share/man/man1
  '';

  meta = with lib; {
    description = "view and extract data from a 3DS OTP";
    homepage = "https://github.com/SciresM/otptool";
    license = licenses.gpl2;
    platforms = platforms.all;
    mainProgram = "otptool";
  };
}
