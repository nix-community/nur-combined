{
  lib,
  stdenvNoCC,
  fetchMsvcSdk,
  writableTmpDirAsHomeHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "msvcSdk";
  version = "17.14.8";

  src = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) version;
    pname = "msvc-download";

    dontUnpack = true;
    dontBuild = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-LjB0mgjfB9r0fG4ontrt1NrKOyWBK5Q89GbSYnM/c/w=";

    installPhase = ''
      mkdir -p "$out"

      ${lib.getExe fetchMsvcSdk} --msvc-version 17.14 --accept-license --dest "$out"
    '';
  };

  dontBuild = true;

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  preInstall = ''
    mkdir -p $out
    cp -a ./ $out
  '';

  postInstall = ''
    ${fetchMsvcSdk}/install.sh $out
  '';

  meta = {
    description = "Windows SDK fixed-up for Linux";
    homepage = "https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/";
    license = lib.licenses.unfree // {
      shortName = "Microsoft Software License";
    };
    maintainers = with lib.maintainers; [ RossSmyth ];
  };
})
