{ installShellFiles, pkgs, stdenv }:

let
  pname = "container-use";
  version = "0.3.1";

  inherit (stdenv.hostPlatform) system;

  shaMap = {
    x86_64-linux = "sha256-6OzlbDZJ3ePM174sssaT37d8jg/Oq1pgaTPhOWPpxtI=";
    aarch64-linux = "sha256-JasZtUB1tUu/XsuLWOgjc6xXGBqk7PYz/xx6i7PsQl0=";
    x86_64-darwin = "sha256-tlHK6FsEufxGc/TYhNY5cXSwmlGIDEG+gwJrT9EMNWY=";
    aarch64-darwin = "sha256-ki4xdfkbMHoB5JU9uYNb+bdtAmSPYh+PNdWOPFLerXM=";
  };

  urlMap = {
    x86_64-linux = "https://github.com/dagger/container-use/releases/download/v${version}/container-use_v${version}_linux_amd64.tar.gz";
    aarch64-linux = "https://github.com/dagger/container-use/releases/download/v${version}/container-use_v${version}_linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/dagger/container-use/releases/download/v${version}/container-use_v${version}_darwin_amd64.tar.gz";
    aarch64-darwin = "https://github.com/dagger/container-use/releases/download/v${version}/container-use_v${version}_darwin_arm64.tar.gz";
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl {
    url = urlMap.${system} or (throw "unsupported system ${system}");
    sha256 = shaMap.${system} or (throw "unsupported system ${system}");
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    install -Dm755 container-use $out/bin/container-use

    # Create cu symlink for backward compatibility
    ln -s $out/bin/container-use $out/bin/cu

    # Install shell completions
    installShellCompletion --cmd container-use \
      --bash completions/container-use.bash \
      --fish completions/container-use.fish \
      --zsh completions/container-use.zsh

    # Install cu completions for backward compatibility
    installShellCompletion --cmd cu \
      --bash completions/cu.bash \
      --fish completions/cu.fish \
      --zsh completions/cu.zsh

    # Install man pages
    installManPage man/*.1

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Containerized environments for coding agents";
    homepage = "https://github.com/dagger/container-use";
    license = licenses.asl20;
    platforms = with platforms; linux ++ darwin;
    mainProgram = "container-use";
  };
}
