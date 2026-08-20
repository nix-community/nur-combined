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
  version = "0.1.17";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "smart-suggestion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KRZPU3ZwCVxV356j7aXbn/Q9U5YAO8plFVOfz/MowLk=";
  };

  vendorHash = "sha256-r3KFDUEo5ekk+unX3fKOgterLyoZu95mmjAIQLJ7HUQ=";
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
