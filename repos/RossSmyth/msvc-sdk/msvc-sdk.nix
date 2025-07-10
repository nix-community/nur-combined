{
  stdenvNoCC,
  fetchMsvcSdk,
  writableTmpDirAsHomeHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "msvc-sdk";
  version = "17.14.5";

  src = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) version;
    pname = "msvc-download";

    dontUnpack = true;
    dontBuild = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-SB9SGiNSN+9yZ3pOsGId78o/tq+crelDHgM2dZP7PiU=";

    installPhase = ''
      mkdir -p "$out"

      ${fetchMsvcSdk}/vsdownload.py --accept-license --dest "$out"
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
})
