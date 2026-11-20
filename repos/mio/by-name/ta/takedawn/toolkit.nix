# Updated by update.sh along with the version in package.nix: each Takedawn
# release has a takedawn-<version> tag in the toolkit.
{ fetchFromGitHub }:
fetchFromGitHub {
  owner = "xenophobentx";
  repo = "xboxrecomp";
  tag = "takedawn-0.3.1";
  hash = "sha256-S/TTN42py4tK4zcHEpSCezO6sPRFf4VMjzgzrEkGk6I=";
}
