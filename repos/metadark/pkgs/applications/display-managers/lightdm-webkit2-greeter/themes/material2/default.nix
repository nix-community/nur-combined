{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "material2";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "FallingSnow";
    repo = "lightdm-webkit2-material2";
    rev = "v${version}";
    sha256 = "1v11nx5gil0jpw8yxhdjh44g1m94vv48iglhh7smibm2nfjb36sa";
  };

  # npm + packages
  buildPhase = "npm run build";

  installPhase = ''
    mkdir -p $out
    cp -r build $out
  '';
}
