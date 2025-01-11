{ pkgs, lib, fetchurl, stdenv }:
let
  pname = "localbooru-bin";
  version = "1.6.0";

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
    hash = "sha256-8tidSYJ0gAyWURi3NUC7p5y96oL3/e0stIVV2+A5PC8=";
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

  postFixup = ''
    makeWrapper $out/usr/share/localbooru/localbooru $out/bin/localbooru-bin \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : $out/usr/share/localbooru/lib:${lib.makeLibraryPath [ pkgs.mpv-unwrapped ]} \
      --prefix PATH : ${lib.makeBinPath [ pkgs.xdg-user-dirs pkgs.zenity ]}
  '';
}
