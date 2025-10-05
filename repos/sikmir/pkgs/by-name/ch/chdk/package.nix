{
  lib,
  stdenv,
  fetchzip,
  gcc-arm-embedded,
  zip,
  platform ? null,
  platformsub ? null,
  fi2key ? null,
  fi2iv ? null,
}:

let
  version = "1.6.1";
  revision = "6315"; # check on http://mighty-hoernsche.de/
  branch = "release-${lib.replaceStrings [ "." ] [ "_" ] (lib.versions.majorMinor version)}";
  optFI2 = fi2key != null && fi2iv != null;
  batchBuild = platform == null || platformsub == null;
in
stdenv.mkDerivation {
  pname = "chdk";
  inherit version;

  src = fetchzip {
    url = "https://app.assembla.com/spaces/chdk/subversion/source/${revision}/branches/${branch}?_format=zip";
    extension = "zip";
    stripRoot = false;
    hash = "sha256-uka+Hn0gUoJS0XX5lqcY/crUx29KQSPrL2/OAg0vQKM=";
  };

  nativeBuildInputs = [
    gcc-arm-embedded
    zip
  ];

  buildFlags =
    [
      "DEF_SVN_REF=${revision}"
      "HOSTCC=${stdenv.cc.targetPrefix}cc"
    ]
    ++ lib.optionals (optFI2 && !batchBuild) [
      "OPT_FI2=1"
      "FI2KEY=${fi2key}"
      "FI2IV=${fi2iv}"
    ]
    ++ lib.optionals (!batchBuild) [
      "PLATFORM=${platform}"
      "PLATFORMSUB=${platformsub}"
      "firzipsubcomplete"
    ]
    ++ lib.optional batchBuild "batch-zip-complete";

  env.NIX_CFLAGS_COMPILE = "-Wno-format-security";

  installPhase = ''
    runHook preInstall
    install -Dm644 bin/*.zip -t $out
    runHook postInstall
  '';

  meta = {
    description = "Canon Hack Development Kit";
    homepage = "https://chdk.fandom.com/wiki/CHDK";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
}
