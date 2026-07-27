{ stdenv
, lib
, fetchFromGitHub

, autoreconfHook
, gnupg
, pam
}:

stdenv.mkDerivation rec {
  pname = "pam-gnupg";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "cruegge";
    repo = "pam-gnupg";
    rev = "v${version}";
    sha256 = "0b70mazyvcbg6xyqllm62rwhbz0y94pcy202db1qyy4w8466bhsw";
  };

  nativeBuildInputs = [
    autoreconfHook
    gnupg
  ];
  buildInputs = [ pam ];

  configureFlags = [ "--with-moduledir=\${out}/lib/security" ];

  meta = with lib; {
    homepage = "https://github.com/cruegge/pam-gnupg";
    description = "Unlock GnuPG keys on login";
    license = licenses.gpl3;
    platforms = pam.meta.platforms;
  };
}
