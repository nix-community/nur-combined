{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update,
  writeShellScript,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "catppuccin-gitea";
  version = "1.0.2";

  src = fetchzip {
    url = "https://github.com/catppuccin/gitea/releases/download/v${finalAttrs.version}/catppuccin-gitea.tar.gz";
    hash = "sha256-rZHLORwLUfIFcB6K9yhrzr+UwdPNQVSadsw6rg8Q7gs=";
    # The release tarball is a flat list of `theme-*.css` files, no top directory.
    stripRoot = false;
  };

  dontConfigure = true;
  dontBuild = true;

  # Forgejo wants a directory whose root holds the `theme-*.css` files: it is
  # symlinked as `custom/public/assets/css` and listed with `builtins.readDir`.
  # The whole tree is copied verbatim to keep that listing unchanged.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out
    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake catppuccin-gitea";

  meta = {
    description = "Soothing pastel theme for Gitea and Forgejo";
    homepage = "https://github.com/catppuccin/gitea";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
})
