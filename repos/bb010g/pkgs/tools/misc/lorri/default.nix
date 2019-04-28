{ stdenv, rustPlatform, fetchFromGitHub
, darwin ? null, nix
}:

let
  inherit (stdenv.lib) optionals substring;
in rustPlatform.buildRustPackage rec {
  pname = "lorri";
  version = "0.1.0-2019-03-31+${substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "target";
    repo = "lorri";
    rev = "a1818308db1ed0d2de7d3cf95db3a669c40612b6";
    sha256 = "0kh3hz0c38d5zhkp41b87q5sngsbkdpk9awx8lihgmas95n07rwm";
  };

  cargoSha256 = "0lx4r05hf3snby5mky7drbnp006dzsg9ypsi4ni5wfl0hffx3a8g";

  buildInputs = [ nix ] ++ optionals stdenv.isDarwin [
    darwin.cf-private
    darwin.security
    darwin.apple_sdk.frameworks.CoreServices
  ];

  doCheck = !stdenv.isDarwin;

  BUILD_REV_COUNT = src.revCount or 1;
  NIX_PATH = "nixpkgs=${src + "/nix/bogus-nixpkgs"}";

  preCheck = ''source ${src + "/nix/pre-check.sh"}'';

  meta = with stdenv.lib; {
    description = "Your project's nix-env";
    longDescription = ''
      lorri is a nix-shell replacement for project development. lorri is based
      around fast direnv integration for robust CLI and editor integration.

      The project is about experimenting with and improving the developer's
      experience with Nix. A particular focus is managing your project's
      external dependencies, editor integration, and quick feedback.
    '';
    homepage = https://github.com/target/lorri;
    license = with licenses; asl20;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}
