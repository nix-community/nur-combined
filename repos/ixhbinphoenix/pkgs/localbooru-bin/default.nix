{ pkgs, lib, fetchurl, stdenv }:
let
  pname = "localbooru-bin";
  version = "1.5.2";

  meta = {
    description = "Cross platform local booru collection that exclusively works on local storage, without selfhosting";
    downloadPage = "https://github.com/resucutie/localbooru/releases";
    homepage = "https://github.com/resucutie/localbooru";
    mainProgram = "localbooru-bin";
    platforms = [
      "x86_64-linux"
    ];
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };

  fetchArtifact = {filename, hash}:
  fetchurl {
    url = "https://github.com/resucutie/localbooru/releases/download/${version}/${filename}";
    inherit hash;
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchArtifact {
    filename = "localbooru-linux.deb";
    hash = "sha256-XSpwIhmATlOKaisQTD7wttOw/kZ1ZXHXwT6PL98WC2s=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = with pkgs; [
    mpv-unwrapped
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';

  preFixup = ''
    patchelf $out/usr/share/localbooru/lib/libmedia_kit_native_event_loop.so \
      --replace-needed libmpv.so.1 libmpv.so
    patchelf $out/usr/share/localbooru/lib/libmedia_kit_video_plugin.so \
      --replace-needed libmpv.so.1 libmpv.so
  '';

  postFixup = ''
    makeWrapper $out/usr/share/localbooru/localbooru $out/bin/localbooru-bin \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : $out/usr/share/localbooru/lib:${lib.makeLibraryPath [ pkgs.mpv-unwrapped ]} \
      --prefix PATH : ${lib.makeBinPath [ pkgs.xdg-user-dirs pkgs.gnome.zenity ]}
  '';
}
