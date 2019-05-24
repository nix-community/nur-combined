{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  version = "v2.2.0";
  name = "mantisbt-plugin-source-integration-${version}";
  src = fetchFromGitHub {
    owner = "mantisbt-plugins";
    repo = "source-integration";
    rev = "44fc9e2e770aff4f40f56833f26a86ce0e2deb76";
    sha256 = "0gcm6kqqijnv303sk59zn27adwx5vkr545mwzyaq2nrpxnkwdy5b";
  };
  patches = [
    ./Source.API.php.diff
  ];
  installPhase = ''
    mkdir $out
    cp -a Source* $out/
    '';
  passthru = {
    selector = "Source*";
  };
}
