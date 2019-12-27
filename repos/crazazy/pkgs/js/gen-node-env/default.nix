{stdenv, fetchFromGitHub, jq, curl, nodePackages}:
stdenv.mkDerivation {
  pname = "nix-gen-node-tools";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "crazazy";
    repo = "nix-gen-node-tools";
    sha256 = "0d4gkck81j18d061d1cfizri7bdhv9h3r8wdh5h9064plnvcdawa";
    rev = "169919ec94091b9ad133edf1dd1d88b154f5ec12";
  };

  buildInputs = [jq curl nodePackages.node2nix];

  installPhase = ''
    install -m755 -D genNodeNix "$out/bin/nix-gen-node-tools"
  '';

  meta = with stdenv.lib; {
    description = "Generates nix expressions for node.js CLI tools written in pure JS";
    license = licenses.asl20;
    homepage = "https://github.com/crazazy/nix-gen-node-tools";
  };
}
