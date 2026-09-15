{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "chat-on-steroids";
  version = "2.1.12";

  src = fetchurl {
    url = "https://github.com/totec448-spec/chat-on-steroids/releases/download/v${version}/Chat-On-Steroids-Linux-x64.AppImage";
    hash = "sha256-deLfbnAqwadjD4amMo2qJecRwob/wjTaFrhTDnzB4Ts=";
  };

  contents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapAppImage {
  # Keep `src` (fetchurl) on the final derivation so nix-update can find
  # `pkg.src.url`; `contents` is what actually runs.
  inherit
    pname
    version
    src
    contents
    ;

  extraInstallCommands = ''
    install -Dm444 \
      ${contents}/com.chatonsteroids.app.desktop \
      $out/share/applications/com.chatonsteroids.app.desktop

    substituteInPlace $out/share/applications/com.chatonsteroids.app.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=chat-on-steroids'

    cp -r \
      ${contents}/usr/share/icons \
      $out/share/
  '';

  meta = {
    description = "Local coding bridge for ChatGPT over MCP, with native desktop control and approved-folder capability limits";
    homepage = "https://github.com/totec448-spec/chat-on-steroids";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "chat-on-steroids";
  };
}
