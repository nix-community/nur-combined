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
  version = "0.1.19";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "smart-suggestion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4/J6FVbmzbnWc2pE4S47sh2UkMwc4MHSdYB4qcx+7+E=";
  };

  vendorHash = "sha256-oetiEnno5GfFexBKJLbIxZiCgedQtcYCXuF1fXb3RdQ=";
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
