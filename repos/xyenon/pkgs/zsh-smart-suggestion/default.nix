{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

# To make use of this derivation, use the `programs.zsh.smart-suggestion.enable` option

buildGoModule (finalAttrs: {
  __structuredAttrs = true;

  pname = "zsh-smart-suggestion";
  version = "0.1.16";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "smart-suggestion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SSWzon2cVnyiHFIXO4Tk2lrOQ7Q6xH0C+JeLlwqYQ+w=";
  };

  vendorHash = "sha256-L9rvgawC051Fy5+XPeS1JkeNBEdyyViRrMyIHzXkN/w=";
  subPackages = [ "cmd/smart-suggestion" ];

  postInstall = ''
    install -D smart-suggestion.plugin.zsh \
      $out/share/zsh/plugins/zsh-smart-suggestion/smart-suggestion.plugin.zsh
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AI-powered command suggestions directly in your zsh shell";
    homepage = "https://github.com/XYenon/smart-suggestion";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ xyenon ];
  };
})
