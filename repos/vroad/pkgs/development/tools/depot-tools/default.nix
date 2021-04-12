{ lib
, stdenv
, fetchurl
, fetchgit
, fetchzip
, python
, python3
, autoPatchelfHook
, gcc-unwrapped
, makeWrapper
}:
let
  rev = "057831ef1f149883e3c26f58a867663f78dc49e1";
  src = fetchgit {
    url = "https://chromium.googlesource.com/chromium/tools/depot_tools.git";
    inherit rev;
    sha256 = "04faq4m1dlk43nwdmfhi6k2vfq053xn4hx334wkzc6r4qs5ayadw";
  };
  cipdClientVersion = "git_revision:e75c9bf286fbb31347379cb478df2a556ab185b1";
  cipdClient = fetchurl {
    name = "cipd";
    url = "https://chrome-infra-packages.appspot.com/client?platform=linux-amd64&version=${cipdClientVersion}";
    sha256 = "1p24w1zy3w2jjk2y7k6gzkhm199f9168w0j5rzxhmw55xp8v08ri";
    executable = true;
  };
  gsutilVersion = "4.30";
  gsutil = fetchzip {
    name = "gsutil";
    url = "https://storage.googleapis.com/pub/gsutil_${gsutilVersion}.zip";
    sha256 = "1xiarvnq49a7z2ai390yz9gzjkhv0snfg4q56w04vgmah10c32lv";
  };
in
stdenv.mkDerivation {
  name = "depot-tools";
  buildInputs = [ gcc-unwrapped ];
  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];
  unpackPhase = ''
    mkdir -p $out/src/
    cp -r ${src}/. $out/src/
    chmod -R u+rwX,go+rX,go-w $out/src/
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/src/third_party/
    ln -sf ${cipdClient} $out/src/cipd
    ln -sf ${gsutil} $out/src/third_party/gsutil
    makeWrapper $out/src/gclient $out/bin/gclient \
      --set DEPOT_TOOLS_UPDATE 0 \
      --set VPYTHON_BYPASS 'manually managed python not supported by chrome operations' \
      --set DEPOT_TOOLS_METRICS 0 \
      --prefix PATH : ${lib.makeBinPath [ python python3 ]}
    makeWrapper $out/src/autoninja $out/bin/autoninja \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
  '';
}
