{ buildGoModule
, fetchFromGitHub
, fzf
, git
, installShellFiles
, lib
, tmux
, procps
}:

buildGoModule rec {
  pname = "swm";
  version = "0.4.0-alpha5";

  src = fetchFromGitHub {
    owner = "kalbasit";
    repo = "swm";
    rev = "v${version}";
    sha256 = "sha256-KnqEmGdTXN//aCJ240Gaz551BIvpd9/X6THpbqbKMAY=";
  };

  vendorSha256 = null;

  ldflags = "-X=github.com/kalbasit/swm/cmd.version=${version}";

  nativeBuildInputs = [ fzf git tmux procps installShellFiles ];

  postInstall = ''
    for shell in bash zsh fish; do
      $out/bin/swm auto-complete $shell > swm.$shell
      installShellCompletion swm.$shell
    done

    $out/bin/swm gen-doc man --path ./man
    installManPage man/*.7
  '';

  doCheck = true;
  preCheck = ''
    export HOME=$NIX_BUILD_TOP/home
    mkdir -p $HOME

    git config --global user.email "nix-test@example.com"
    git config --global user.name "Nix Test"
  '';

  meta = with lib; {
    homepage = "https://github.com/kalbasit/swm";
    description = "swm (Story-based Workflow Manager) is a Tmux session manager specifically designed for Story-based development workflow";
    license = licenses.mit;
    maintainers = [ maintainers.kalbasit ];
  };
}
