{ stdenv, fetchurl }:

let
  rev = "56bd759df1d0c750a065b8c845e93d5dfa6b549d";
  mkUrl = viewMode: rev: 
    "https://gitweb.gentoo.org/repo/gentoo.git/${viewMode}/app-shells/zsh/files/prompt_gentoo_setup-1?id=${rev}";
in stdenv.mkDerivation rec {
  pname = "zsh-prompt-gentoo";
  version = "2015-08-08";
  src = fetchurl {
    url = mkUrl "plain" rev;
    sha256 = "1q9hdv1ajdkxv8n1ynpf90z3fggipqab22kj5syhc52wd7jyv2l1";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    install -d $out/share/zsh/
    cp $src $out/share/zsh/prompt_gentoo_setup
  '';

  meta = with stdenv.lib; let
      url = mkUrl "tree" "master";
    in {
    description = "Extremely simple zsh prompt from Gentoo";
    homepage = url;
    downloadPage = url;
    license = licenses.gpl2;
    platforms = platforms.all;
    hydraPlatforms = [];
  };
}
