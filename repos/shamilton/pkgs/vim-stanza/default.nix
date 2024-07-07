{ lib
, buildVimPlugin
, fetchFromGitHub
, coreutils
}:

buildVimPlugin {

  pname = "stanza";
  version = "2019-08-09";

  src = fetchFromGitHub {
    owner = "jcmartin";
    repo = "stanza.vim";
    rev = "b8ef2ef7312569208a1ba97982e2b4d43ce54fb5";
    sha256 = "sha256:0gd92q26lir2mrgjiyva4f368sgp06xc1gfcf730zi633yilf8hm";
  };

  meta = with lib; {
    description = "Stanza syntax highlighting";
    license = licenses.gpl2;
    homepage = "https://github.com/arrufat/vala.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
