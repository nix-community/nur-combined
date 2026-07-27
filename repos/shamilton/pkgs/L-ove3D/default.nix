{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
# , nix-gitignore
, love
}:
stdenv.mkDerivation rec {
  pname = "L-ve3D";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "L-ve3D";
    rev = "0e048e3b3206a6acbe9a0d2ca097882c43fc1f51";
    sha256 = "sha256-I7kseSwHy6SLsBlPmHocyOcCJYMEBv1ieSTToz+XfdE=";
  };
  # src = nix-gitignore.gitignoreSource [ ] ~/GIT/L-ve3D;

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ love ];

  installPhase = ''
    mkdir -p "$out/src/${pname}"
    cp -r ./* "$out/src/${pname}"

    mkdir -p $out/bin
    makeWrapper ${love}/bin/love $out/bin/${pname} \
      --add-flags "$out/src/${pname}"
  '';

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
