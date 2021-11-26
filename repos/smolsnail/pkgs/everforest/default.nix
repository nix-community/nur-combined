{ buildVimPlugin, fetchFromGitHub, lib }:

buildVimPlugin rec {
  pname = "everforest";
  version = "0.2.1";
  src = fetchFromGitHub {
    owner = "sainnhe";
    repo = pname;
    rev = "v${version}";
    sha256 = "13y181b7mi4qpi40cjrw96m2s0byx4rwh25iy1lam2y4kyinj449";
  };
  meta = with lib; {
    description = "Comfortable & Pleasant Color Scheme for Vim";
    longDescription = ''
      Everforest is a green based color scheme,
      it's designed to be warm and soft in order to protect developers' eyes.
    '';
    homepage = "https://github.com/sainnhe/everforest";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
