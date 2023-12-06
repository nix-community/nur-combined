{ lib, stdenv, fetchzip, autoPatchelfHook, writeShellScript
, libglvnd, glibc, alsaLib, SDL2
}:

let
  script = writeShellScript "pixitracker-launch" ''
    cd @out@/lib
    ./bin/pixilang_linux_x86_64 boot.pixicode
  '';
in
stdenv.mkDerivation rec {
  pname = "pixitracker";
  version = "1.6.5";
  
  src = fetchzip {
    url = "https://www.warmplace.ru/soft/pixitracker/${pname}-${version}.zip";
    sha256 = "sha256-X4FnITdLs2WXJvM6nSZH2ANUBb7BT8J1FgCQ21j4fa4=";
  };
  
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ libglvnd glibc alsaLib SDL2 ];
  
  installPhase = ''
    runHook preInstall;
    
    mkdir -p "$out/lib" "$out/bin"
    mv * "$out/lib"
    
    cp ${script} $out/bin/pixitracker
    sed -i s#@out@#$out# $out/bin/pixitracker
    
    runHook postInstall;
  '';
  
}
