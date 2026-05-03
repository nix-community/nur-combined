{
  appimageTools,
  fetchurl,
  lib,
  stdenv,
}:

appimageTools.wrapType2 rec {
  pname = "multica";
  version = "0.2.24";

  src =
    passthru.sources.${stdenv.hostPlatform.system}
      or (throw "${pname} is not supported on ${stdenv.hostPlatform.system}");

  passthru = {
    sources = {
      x86_64-linux = fetchurl {
        url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-desktop-${version}-linux-x86_64.AppImage";
        hash = "sha256-nKzrF36lffpTmW/x/c7lvAcJSW9TAsAIPALPIjgD/gw=";
      };
      aarch64-linux = fetchurl {
        url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-desktop-${version}-linux-arm64.AppImage";
        hash = "sha256-iAchE5p8sq3sA+1Rd35Zi9EC5oXxoKejxFBYy2/a02A=";
      };
    };
  };

  meta = {
    description = "Your next 10 hires won't be human.";
    longDescription = ''
      An open-source platform that turns coding agents into real teammates.
      Assign tasks, track progress, compound skills — manage your human + agent workforce in one place.
    '';
    homepage = "https://multica.ai";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "multica";
    maintainers = [ lib.maintainers.MH0386 ];
  };
}
