{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "buildkite-cli-${version}";
  version = "0.4.0";
  rev = "v${version}";

  goPackagePath = "github.com/buildkite/cli";

  src = fetchFromGitHub {
    inherit rev;
    owner = "buildkite";
    repo  = "cli";
    sha256 = "1sjh0r10wg1j166dgraqkkssjkix0gwyf8l3y25748r41744ypdn";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "A command line interface for Buildkite";
    homepage = https://github.com/buildkite/cli;
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.mit;
  };
}
