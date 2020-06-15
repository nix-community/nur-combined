{stdenv, fetchzip, jq, curl, node2nix, sources}:
stdenv.mkDerivation {
  pname = "nix-gen-node-tools";
  version = "1.0.2";

  src = fetchzip { inherit (sources.nix-gen-node-tools) url sha256; };

  buildInputs = [jq curl node2nix];

  installPhase = ''
    install -m755 -D genNodeNix "$out/bin/nix-gen-node-tools"
    install -m755 -D ${jq}/bin/jq "$out/bin/jq"
    install -m755 -D ${curl}/bin/curl "$out/bin/curl"
    install -m755 -D ${node2nix}/bin/node2nix "$out/bin/node2nix"
  '';

  meta = with stdenv.lib; {
    description = "Generates nix expressions for node.js CLI tools written in pure JS";
    license = licenses.asl20;
    homepage = "https://github.com/crazazy/nix-gen-node-tools";
  };
}
