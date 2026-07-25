{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  fetchurl,
  makeDesktopItem,
  sing-box-beta,
  sing-box-dashboard,
  stdenvNoCC,

  # nativeBuildInputs
  buf,
  copyDesktopItems,
  cpio,
  makeBinaryWrapper,
  pbzx,
  pnpm_11,
  pnpmConfigHook,
  xar,

  # buildInputs
  electron_43,
}:
let
  pname = "sing-box-app-beta";

  meta = {
    description = "Client for sing-box";
    downloadPage = "https://github.com/SagerNet/sing-box/releases";
    license = lib.licenses.gpl3Plus;
    # sourceProvenance
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "sing-box-app";
  };
in
if stdenvNoCC.hostPlatform.isDarwin then
  import ./darwin.nix {
    inherit
      pname
      meta
      ;

    inherit
      lib
      fetchurl
      stdenvNoCC
      cpio
      makeBinaryWrapper
      pbzx
      xar
      ;
  }
else
  import ./linux.nix {
    inherit
      pname
      meta
      ;

    inherit
      lib
      buildNpmPackage
      fetchFromGitHub
      fetchPnpmDeps
      makeDesktopItem
      sing-box-beta
      sing-box-dashboard
      buf
      copyDesktopItems
      makeBinaryWrapper
      pnpm_11
      pnpmConfigHook
      electron_43
      ;
  }
