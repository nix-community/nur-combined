{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  cacert,
  fontconfig,
  libidn,
  libxml2,
  zlib,
}: let
  pname = "prince-bin";
  version = "16.2";
  runtimeLibs = [
    fontconfig
    libidn
    libxml2
    zlib
  ];
  arch =
    if stdenvNoCC.hostPlatform.system == "x86_64-linux"
    then "x86_64"
    else "aarch64";
  src =
    if stdenvNoCC.hostPlatform.system == "x86_64-linux"
    then
      fetchurl {
        url = "https://www.princexml.com/download/prince-${version}-linux-generic-x86_64.tar.gz";
        sha256 = "131eece0b07ee832adef8291c6056156b3d04bfebc11ca40274948f8e40a8bbc";
      }
    else if stdenvNoCC.hostPlatform.system == "aarch64-linux"
    then
      fetchurl {
        url = "https://www.princexml.com/download/prince-${version}-linux-generic-aarch64.tar.gz";
        sha256 = "4ea3d160724456d8174ec219bef1d1604ad351ed6229867bf1459e2cdbfab258";
      }
    else throw "Unsupported system for ${pname}: ${stdenvNoCC.hostPlatform.system}";
in
  stdenvNoCC.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = runtimeLibs;

    sourceRoot = "prince-${version}-linux-generic-${arch}";

    installPhase = ''
      runHook preInstall

      install -d "$out/bin" "$out/lib" "$out/share/licenses/prince" "$out/share/doc/prince"

      cp -a lib/prince "$out/lib/"

      ln -sf "${cacert}/etc/ssl/certs/ca-bundle.crt" "$out/lib/prince/etc/curl-ca-bundle.crt"

      install -Dm644 LICENSE CREDITS -t "$out/share/licenses/prince"
      install -Dm644 README -t "$out/share/doc/prince"

      makeWrapper "$out/lib/prince/bin/prince" "$out/bin/prince" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Convert HTML documents to PDF with CSS";
      homepage = "https://www.princexml.com/";
      license = licenses.unfree;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "prince";
      maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
    };
  }
