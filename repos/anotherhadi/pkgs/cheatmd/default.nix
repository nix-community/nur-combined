{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "cheatmd";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cheatmd-dev";
    repo = "cheatmd";
    rev = "v${version}";
    hash = "sha256-939bFkzQcaUH7J8l+C0CkooCvV15MRmYmpOnRgei4LQ=";
  };

  vendorHash = "sha256-C3E64LYi5ReqQT9WcN8KFhi3oUkenfXf/1Y/s/sb4Mg=";

  subPackages = [ "cmd/cheatmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  meta = with lib; {
    description = "Executable Markdown cheatsheets with variable prompts, pickers, and shell integration for bash/zsh/tmux/zellij";
    homepage = "https://cheatmd.dev";
    changelog = "https://github.com/cheatmd-dev/cheatmd/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ ];
    mainProgram = "cheatmd";
  };
}
