{ sources, pkg-config, lib, installShellFiles, darwin, stdenv, rustPlatform, fetchFromGitHub, ... }:
rustPlatform.buildRustPackage rec {
  pname = "gping";
  version = "master";
  src =
    fetchFromGitHub { inherit (sources.gping) owner repo rev sha256; };
  cargoSha256 = "0f4j5zsn3ax60pw2d91kwn78mpw0m9m8hkmhxb8vvw2842sh6k8d";
  nativeBuildInputs = [ installShellFiles ]
    ++ stdenv.lib.optionals stdenv.isLinux [ pkg-config ];
  buildInputs = stdenv.lib.optional stdenv.hostPlatform.isDarwin
    darwin.apple_sdk.frameworks.IOKit;
  doCheck = true;
  meta = with lib; {
    homepage = "https://github.com/orf/gping";
    description =
      "Ping, but with a graph.";
    license = licenses.mit;
  };
}
