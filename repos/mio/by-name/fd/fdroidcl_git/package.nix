{
  lib,
  buildGoModule,
  fetchFromGitHub,
  android-tools,
}:

buildGoModule (finalAttrs: {
  pname = "fdroidcl";
  version = "0.8.1-unstable-2026-05-23";

  src = fetchFromGitHub {
    owner = "Hoverth";
    repo = "fdroidcl";
    rev = "d870160f16a22836d13f59acdabcd70709c68db6";
    hash = "sha256-1vhuZUqkN6hTWfhMfhGzcQBj30HH1Jb0r8G+mBQ9G3M=";
  };

  vendorHash = "sha256-PNj5gkFj+ruxv1I4SezJxebDO2e1qGTYp3ZgekRLNt0=";

  postPatch = ''
    substituteInPlace adb/{server,device}.go \
      --replace-fail 'exec.Command("adb"' 'exec.Command("${android-tools}/bin/adb"'
  '';

  # TestScript/search attempts to connect to fdroid
  doCheck = false;

  meta = {
    description = "F-Droid command line interface written in Go";
    mainProgram = "fdroidcl";
    homepage = "https://github.com/Hoverth/fdroidcl";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
})
