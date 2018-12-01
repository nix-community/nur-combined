{ stdenv, lib, fetchFromGitHub, removeReferencesTo, go}:

stdenv.mkDerivation rec {
  name = "stellar-${version}";
  version = "0.1.0";
  commit = "92a8e36";
  #commit = "ae539df";
  #rev = "v${version}";
  rev = "7f1ebfb50c282411295cbf1f52d3668551a705a8";

  src = fetchFromGitHub {
    inherit rev;
    #owner = "ehazlett";
    #repo = "stellar";
    owner = "vdemeester";
    repo = "stellar";
    sha256 = "0yhzak7rs8v07jp9nk3212d55j34np7d6dvw7d8yx4h1azm1cv60";
  };

  makeFlags = ["COMMIT=${commit}"];

  buildInputs = [ removeReferencesTo go];

  preConfigure = ''
    # Extract the source
    cd "$NIX_BUILD_TOP"
    mkdir -p "go/src/github.com/ehazlett"
    mv "$sourceRoot" "go/src/github.com/ehazlett/stellar"
    export GOPATH=$NIX_BUILD_TOP/go:$GOPATH
  '';

  preBuild = ''
    cd go/src/github.com/ehazlett/stellar
    patchShebangs .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/* $out/bin
  '';

  preFixup = ''
    find $out -type f -exec remove-references-to -t ${go} '{}' +
  '';

  meta = {
    description = "Simplified Container Runtime Cluster";
    homepage = "https://github.com/ehazlett/stellar";
    licence = lib.licenses.mit;
  };
}
