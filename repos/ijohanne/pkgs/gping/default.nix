{ sources, pkg-config, lib, installShellFiles, darwin, stdenv, rustPlatform, fetchFromGitHub, ... }:
rustPlatform.buildRustPackage rec {
  pname = "gping";
  version = "master";
  src =
    fetchFromGitHub { inherit (sources.gping) owner repo rev sha256; };
  cargoSha256 = "1w2a17dqjk92hw2ysja7lvgl7zvdy2dhwlpwad243lvykh5lrp70";
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
