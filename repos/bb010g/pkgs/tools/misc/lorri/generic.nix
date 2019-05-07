{ pname ? "lorri", version, src, cargoSha256 } @ versionArgs:
{ stdenv, rustPlatform, fetchFromGitHub
, darwin ? null, nix
}:

let
  inherit (stdenv.lib) optionals substring;
in rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub ({
    owner = "target";
    repo = "lorri";
  } // versionArgs.src);

  inherit cargoSha256;

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
