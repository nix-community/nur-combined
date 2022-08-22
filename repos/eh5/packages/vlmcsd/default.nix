# taken from https://github.com/pborzenkov/nur-packages
{ lib
, stdenv
, fetchFromGitHub
}: stdenv.mkDerivation rec {
  pname = "vlmcsd";
  version = "1113";

  src = fetchFromGitHub {
    owner = "Wind4";
    repo = "vlmcsd";
    rev = "svn${version}";
    sha256 = "19qfw4l4b5vi03vmv9g5i7j32nifvz8sfada04mxqkrqdqxarb1q";
  };

  installPhase = ''
    mkdir -p $out
    pushd bin
    for b in vlmcs{,d}; do
      install -D -m755 $b "$out/bin/$b"
    done
    popd
    pushd man
    for m in *.[0-9]; do
      s=''${m##*.}
      install -Dm644 $m "$out/share/man/man$s/$m"
    done
    popd
  '';

  meta = with lib; {
    description = "KMS Emulator in C";
    homepage = "https://github.com/Wind4/vlmcsd";
    license = with licenses; [ free ];
  };
}
