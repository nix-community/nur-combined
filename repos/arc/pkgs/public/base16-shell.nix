{ stdenvNoCC, fetchFromGitHub }: let
  rev = "ce8e1e540367ea83cc3e01eec7b2a11783b3f9e1";
in stdenvNoCC.mkDerivation rec {
  pname = "base16-shell";
  version = rev;
  src = fetchFromGitHub {
    owner = "chriskempson";
    repo = pname;
    inherit rev;
    sha256 = "1yj36k64zz65lxh28bb5rb5skwlinixxz6qwkwaf845ajvm45j1q";
  };

  buildPhase = "true";
  installPhase = ''
    cp -a . $out
  '';
}
