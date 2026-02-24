{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

# To make use of this derivation, use the `programs.zsh.smart-suggestion.enable` option

buildGoModule rec {
  pname = "zsh-smart-suggestion";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "smart-suggestion";
    tag = "v${version}";
    hash = "sha256-kq4ixiSUKUlxni7w/5MjDxll900T0fxO1pIzfzg+MDE=";
  };

  vendorHash = "sha256-H8S27E+ER2rfn3Y5PATC434O/em56GY0ShsQ+m1wm+4=";
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
