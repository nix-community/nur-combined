{ buildGoModule, fetchFromGitHub, lib }:
buildGoModule rec {
  pname = "wavelog-stoat";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "int2001";
    repo = "WaveLogStoat";
    rev = "v${version}";
    hash = "sha256-oBZFo8mTtW/UvVPrwdEj32fWVYFTjgDBKK+UMOhlspg=";
  };

  vendorHash = "sha256-f444cTmN5WrgcFTvF2+cl98wc1ASpGH+2LCy0/81Up4=";
}
