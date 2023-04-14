{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  pkg-config,
  libtool,
  openssl,
}:
stdenv.mkDerivation rec {
  pname = "pkcs11-provider";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "latchset";
    repo = pname;
    rev = "v${version}";
    sha256 = "1qzc51r6p1ismqk363lla7z6fwxqr3786szn71lk7wrcpqi42z4l";
  };

  nativeBuildInputs = [autoconf-archive autoreconfHook pkg-config libtool];

  buildInputs = [openssl];

  enableParallelBuilding = true;

  passthru = {inherit openssl;};

  meta = with lib; {
    description = "This is an Openssl 3.x provider to access Hardware or Software Tokens using the PKCS#11 Cryptographic Token Interface";
    homepage = "https://github.com/latchset/pkcs11-provider/";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
