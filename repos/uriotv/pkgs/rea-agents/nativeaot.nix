{
  lib,
  stdenv,
  fetchzip,
  fetchurl,
  ghidra,
  jdk21,
}:

let
  revision = "a56f7bb668ab23fec8d33f7af353ac7ed2fe1895";
  facade =
    lib.mapAttrsToList
      (
        name: sha256:
        fetchurl {
          url = "https://raw.githubusercontent.com/morluto/rea/${revision}/bridge/nativeaot/${name}.java";
          inherit sha256;
        }
      )
      {
        NativeAotDirectory = "sha256-Nk9PBlkmpK2bTJXzJ3Lr94LtRwwEMjJvJluKWdaV4P0=";
        NativeAotExtension = "sha256-YPszhRv9fCfhs/LuKH2JqjVWBdMxQRjv7PXje/cYYgI=";
        NativeAotMethodConventions = "sha256-LU7JpbWCXb4fRAnMYLyrMl8+EwUwI4XnS7msbP9iCuE=";
        NativeAotTypeMetadata = "sha256-eYgossTD0q49fPUQ4wU8f9ZxAEGTY7zQKZe0gBanAZI=";
      };
in
stdenv.mkDerivation {
  pname = "rea-ghidra-nativeaot";
  version = "6.4.0";
  src = fetchzip {
    url = "https://github.com/Washi1337/ghidra-nativeaot/archive/effeb734fc570c32650f88b159608979dc7b423e.tar.gz";
    hash = "sha256-ZleuiPZYrK9CH2/689iLttbYiFuU12rg6D8myu/ugs4=";
  };
  nativeBuildInputs = [ jdk21 ];
  buildPhase = ''
    runHook preBuild
    mkdir -p classes facade
    ${lib.concatMapStringsSep "\n" (file: "cp ${file} facade/${file.name}") facade}
    find src/main/java facade -name '*.java' -print > sources.txt
    classpath=$(find ${ghidra}/lib/ghidra/Ghidra -name '*.jar' -printf '%p:' | sort)
    javac -J-Xmx512m -J-XX:ActiveProcessorCount=1 --release 21 \
      -proc:none -cp "$classpath" -d classes @sources.txt
    cp LICENSE.md classes/LICENSE-ghidra-nativeaot.md
    jar --create --file rea-ghidra-nativeaot.jar --date=2025-01-01T00:00:00Z -C classes .
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    install -Dm444 rea-ghidra-nativeaot.jar "$out/share/java/rea-ghidra-nativeaot.jar"
    runHook postInstall
  '';
  meta = {
    description = "Optional NativeAOT Ghidra adapter for REA";
    homepage = "https://github.com/Washi1337/ghidra-nativeaot";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
