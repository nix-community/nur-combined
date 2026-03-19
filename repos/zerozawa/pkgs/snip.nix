{
  buildGo126Module,
  fetchFromGitHub,
  lib,
}:
buildGo126Module rec {
  pname = "snip";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "edouard-claude";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-qBQoeRWvxIbg8JWhUCRWQ58AMeF1iYqQMEA6FA7UGW0=";
  };

  vendorHash = "sha256-2MxFZqjNuLzcuu+bsLyOyHIakCxh7j0FUx8LsjZRhrY=";

  # Risk on future updates: this assumes the module root stays at repo root,
  # the CLI entrypoint stays under cmd/snip, and Go <= 1.26 remains sufficient.
  subPackages = ["cmd/snip"];

  env.CGO_ENABLED = 0;

  postPatch = ''
    substituteInPlace internal/cli/cli.go \
      --replace-fail 'const version = "0.1.0"' 'var version = "0.1.0"'
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/edouard-claude/snip/internal/cli.version=${version}"
  ];

  meta = with lib; {
    description = "CLI proxy that reduces LLM token consumption by filtering shell output";
    homepage = "https://github.com/edouard-claude/snip";
    license = with licenses; [mit];
    mainProgram = pname;
    platforms = platforms.linux ++ platforms.darwin;
    sourceProvenance = with sourceTypes; [fromSource];
  };
}