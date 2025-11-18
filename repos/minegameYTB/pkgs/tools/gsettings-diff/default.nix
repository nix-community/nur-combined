{ lib, stdenvNoCC, makeWrapper, glib, coreutils, diffutils, }:

### found here (https://blog.lazy-evaluation.net/posts/linux/gsettings-diff.html (web archive: https://web.archive.org/web/20250323112054/https://blog.lazy-evaluation.net/posts/linux/gsettings-diff.html))

stdenvNoCC.mkDerivation rec {
  pname = "gsettings-diff";
  version = "0.0.0";

  src = ./gsettings-diff;

  buildInputs = [ glib coreutils diffutils makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    ### Make gsettings-diff available
    mkdir -p $out/bin
    cp ${src} $out/bin/${pname}

    ### Change to executable file
    chmod +x $out/bin/${pname}
  '';

  postFixup = ''
    ### Add runtime path to gsettings-diff wrapper
    wrapProgram $out/bin/${pname} \
      --set PATH ${lib.makeBinPath [ glib coreutils diffutils ]}
  '';

  meta = {
    description = "GSettings from GUI to Command Line";
    homepage = "https://blog.lazy-evaluation.net/posts/linux/gsettings-diff.html";
    mainProgram = "gsettings-diff";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
