{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  version = "72b8577-master";
  name = "dokuwiki-plugin-farmer-${version}";
  src = fetchFromGitHub {
    owner = "cosmocode";
    repo = "dokuwiki-plugin-farmer";
    rev = "72b857734fd164bf79cc6e17abe56491d55c1072";
    sha256 = "1c9vc1z7yvzjz4p054kshb9yd00a4bb52s43k9zav0lvwvjij9l0";
  };
  installPhase = ''
    mkdir $out
    cp -a * $out
    '';
  passthru = {
    pluginName = "farmer";
    preload = out: ''
      # farm setup by farmer plugin
      if (file_exists('${out}/DokuWikiFarmCore.php'))
      {
        include('${out}/DokuWikiFarmCore.php');
      }
    '';
  };
}
