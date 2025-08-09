{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "arnis";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "louis-e";
    repo = "arnis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xvVG5LCVbAB7y+0usuVDQEeIH09geIL0s1n6rZGWvAU=";
  };

  cargoHash = "sha256-J2ymz+lV30UFZqIpynxH6TA8zNgauaoAQon5WsPJONY=";

  meta = {
    description = "Generate real life cities in Minecraft";
    homepage = "https://github.com/louis-e/arnis";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.hostPlatform.isLinux;
  };
})
