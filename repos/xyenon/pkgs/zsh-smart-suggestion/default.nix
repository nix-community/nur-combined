{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

# To make use of this derivation, use the `programs.zsh.smart-suggestion.enable` option

buildGoModule rec {
  pname = "zsh-smart-suggestion";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "smart-suggestion";
    tag = "v${version}";
    hash = "sha256-W2g8/TkQ2dxwkAObF1vO4TBhzBOsKyZHo2ip6Hd6HtU=";
  };

  vendorHash = "sha256-2mtBTnvxXjQPXO2/FFljkO15fsIu41liyU5FI0UQ82c=";
  subPackages = [ "cmd/smart-suggestion" ];

  postInstall = ''
    install -D smart-suggestion.plugin.zsh \
      $out/share/zsh/plugins/zsh-smart-suggestion/smart-suggestion.plugin.zsh
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "AI-powered command suggestions directly in your zsh shell";
    homepage = "https://github.com/XYenon/smart-suggestion";
    license = licenses.unlicense;
    platforms = platforms.unix;
    maintainers = with maintainers; [ xyenon ];
  };
}
