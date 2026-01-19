{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "surge";
  version = "0.1.9";

  # https://github.com/junaid2005p/surge
  src = fetchFromGitHub {
    owner = "junaid2005p";
    repo = "surge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IVPm6f9okp626h8X93mnQMAvQgmow210WacX3r/G4T4=";
  };

  vendorHash = "sha256-pkYm14M9d9Aa9HO2Z7q2aoQmkt76igLJHH+U8T7otTo=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  # Disable tests that try to create directories in user config paths
  doCheck = false;

  meta = {
    description = "Surge is an open-source download manager";
    homepage = "https://github.com/junaid2005p/surge";
    mainProgram = "surge";
    binaryNativeCode = true;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
