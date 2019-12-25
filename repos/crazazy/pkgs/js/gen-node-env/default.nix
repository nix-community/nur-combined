{stdenv, fetchFromGitHub, jq, curl, nodePackages}:
stdenv.mkDerivation {
  pname = "nix-gen-node-tools";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "crazazy";
    repo = "nix-gen-node-tools";
    sha256 = "0ydqr1qk5kbzpcsligy6nrml0wiwdhc53q2wdcxjzlq9rdijlzxc";
    rev = "dd565f81b3a977ec3e938e5de28d36d653aa3853";
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
