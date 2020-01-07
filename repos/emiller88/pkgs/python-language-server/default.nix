{ stdenv, lib, fetchurl, unzip, makeWrapper, dotnet-sdk }:

let
  pname = "python-language-server";
  version = "0.2";

  os = if stdenv.isDarwin then "osx" else "linux";
  arch = with stdenv.hostPlatform;
    if isx86_32 then
      "x86"
    else if isx86_64 then
      "x64"
    else if isAarch32 then
      "arm"
    else if isAarch64 then
      "arm64"
    else
      lib.warn
      "Unsupported architecture, some image processing features might be unavailable"
      "unknown";
  musl = lib.optionalString stdenv.hostPlatform.isMusl (if (arch != "x64") then
    lib.warn
    "Some image processing features might be unavailable for non x86-64 with Musl"
    "musl-"
  else
    "musl-");
  runtimeDir = "${os}-${musl}${arch}";

in stdenv.mkDerivation rec {
  src = fetchurl {
    url = "${meta.homepage}/archive/${version}.tar.gz";
    sha256 = "63a16a1369bc9c6d7b24c12044e3d2e341264f65ac38bd16bf01576f6cceb3df";
  };

  buildInputs = [ unzip makeWrapper ];

  propagatedBuildInputs = [ dotnet-sdk ];

  preferLocalBuild = true;

  installPhase = ''
    install -dm 755 "$out/opt/${pname}-${version}"
    cd "$out/opt/${pname}-${version}/src/LanguageServer/Impl"

    makeWrapper "${dotnet-sdk}/bin/dotnet" publish -c Release -r ${runtimeDir}
    chmod a+x $(git rev-parse --show-toplevel)/output/bin/Release/${runtimeDir}/publish/Microsoft.Python.LanguageServer
  '';

  meta = {
    description = "Microsoft Language Server for Python ";
    homepage = "https://github.com/microsoft/python-language-server";
    # platforms = [ "x86_64-linux" ];
    license = "Apache-2.0";
    # maintainers = with maintainers; [ emiller88 ];
  };
}
