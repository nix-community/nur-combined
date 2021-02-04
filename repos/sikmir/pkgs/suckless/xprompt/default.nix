{ lib, stdenv, fetchFromGitHub, libX11, libXft, libXinerama }:

stdenv.mkDerivation rec {
  pname = "xprompt";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "phillbush";
    repo = "xprompt";
    rev = "v${version}";
    sha256 = "00i4zlypsbh43w0xkjlhy768d8s26kcf15rpbf62viffkg8s4z7w";
  };

  buildInputs = [ libX11 libXft libXinerama ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A dmenu rip-off with contextual completion";
    homepage = "https://github.com/phillbush/xprompt";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}
