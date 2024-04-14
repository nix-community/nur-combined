{ lib
, fetchFromGitHub
, rustPlatform
, ffmpeg
}:

rustPlatform.buildRustPackage rec {
  pname = "ab-av1";
  version = "0.7.14";

  src = fetchFromGitHub {
    owner = "alexheretic";
    repo = "ab-av1";
    rev = "v${version}";
    hash = "sha256-cDabGXNzusVnp4exINqUitEL1HnzSgpcRtYXU5pSRhY=";
  };

  cargoHash = "sha256-sW/673orvK+mIUqTijpNh4YGd9ZrgSveGT6F1O5OYfI=";

  propagatedBuildInputs = [
    ffmpeg
  ];

  meta = with lib; {
    description = "AV1 video encoding tool with fast VMAF sampling & automatic encoder crf calculation.";
    homepage = "https://github.com/alexheretic/ab-av1";
    changelog = "https://github.com/alexheretic/ab-av1";
    license = with licenses; [ mit ];
    maintainers = [ "Jitterbug" ];
  };
}
