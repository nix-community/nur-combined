{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "ab-av1";
  version = "0.7.17";

  src = fetchFromGitHub {
    owner = "alexheretic";
    repo = "ab-av1";
    rev = "v${version}";
    hash = "sha256-QPelXqJT3zbVP+lNiczrCR+JD4icimSyCravlIwTAyw=";
  };

  cargoHash = "sha256-7h1Hbtsk0pnoPXX5sFfzcZoH/sqcb0YTpmJp6yCzTG0=";

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = ''
    installShellCompletion --cmd $pname \
      --bash <($out/bin/ab-av1 print-completions bash) \
      --fish <($out/bin/ab-av1 print-completions fish) \
      --zsh <($out/bin/ab-av1 print-completions zsh)
  '';

  meta = with lib; {
    description = "AV1 video encoding tool with fast VMAF sampling & automatic encoder crf calculation.";
    homepage = "https://github.com/alexheretic/ab-av1";
    changelog = "https://github.com/alexheretic/ab-av1";
    license = with licenses; [ mit ];
    maintainers = [ "Jitterbug" ];
  };
}
