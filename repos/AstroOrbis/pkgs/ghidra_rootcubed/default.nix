{
  stdenv,
  fetchzip,
  lib,
  makeWrapper,
  autoPatchelfHook,
  openjdk21,
  pam,
  makeDesktopItem,
  icoutils,
}:

let

  pkg_path = "$out/lib/ghidra";

  desktopItem = makeDesktopItem {
    name = "ghidra";
    exec = "ghidra";
    icon = "ghidra";
    desktopName = "Ghidra";
    genericName = "Ghidra Software Reverse Engineering Suite";
    categories = [ "Development" ];
    terminal = false;
    startupWMClass = "ghidra-Ghidra";
  };

in
stdenv.mkDerivation rec {
  pname = "ghidra_rootcubed";
  version = "12.2";
  versiondate = "20260515";
  longdate = "2026-05-15";
  src = fetchzip {
    url = "https://github.com/RootCubed/ghidra-ci/releases/download/${longdate}/ghidra_${version}_DEV_${versiondate}.zip";
    hash = "sha256-cdo9cLZXZi/5/2+eg/NaKx+T0dAgfjjew0VDEf9FDkI=";
  };

  nativeBuildInputs = [
    makeWrapper
    icoutils
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    pam
  ];

  dontStrip = true;

  installPhase = ''
    mkdir -p "${pkg_path}"
    mkdir -p "${pkg_path}" "$out/share/applications"
    cp -a * "${pkg_path}"
    ln -s ${desktopItem}/share/applications/* $out/share/applications

    icotool -x "${pkg_path}/support/ghidra.ico"
    rm ghidra_4_40x40x32.png
    for f in ghidra_*.png; do
      res=$(basename "$f" ".png" | cut -d"_" -f3 | cut -d"x" -f1-2)
      mkdir -pv "$out/share/icons/hicolor/$res/apps"
      mv "$f" "$out/share/icons/hicolor/$res/apps/ghidra.png"
    done;
  '';

  postFixup = ''
    mkdir -p "$out/bin"
    ln -s "${pkg_path}/ghidraRun" "$out/bin/ghidra"
    ln -s "${pkg_path}/support/analyzeHeadless" "$out/bin/ghidra-analyzeHeadless"

    wrapProgram "${pkg_path}/support/launch.sh" \
      --prefix PATH : ${lib.makeBinPath [ openjdk21 ]}
  '';

  meta = {
    mainProgram = "ghidra";
    homepage = "https://github.com/RootCubed/ghidra-ci";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.asl20;
  };

}
