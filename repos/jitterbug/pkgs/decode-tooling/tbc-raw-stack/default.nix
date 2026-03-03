{
  maintainers,
  lib,
  fetchFromGitHub,
  rustPlatform,
  ...
}:
let
  pname = "tbc-raw-stack";
  version = "0.2.0";

  rev = version;
  hash = "sha256-wJVfONhmzMwfrJq/jd63PeW7iPZ3u3hvHvBeP7wfoHI=";
  cargoHash = "sha256-8HRguv0/GnCkmSDQ8WnNNKMFmf4FihaTP7leNWTFzdk=";
in
rustPlatform.buildRustPackage {
  inherit pname version cargoHash;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "namazso";
    repo = "tbc-raw-stack";
  };

  postPatch = ''
    substituteInPlace src/main.rs \
      --replace-fail "#![feature(stdarch_x86_avx512)]" "" \
      --replace-fail "#![feature(avx512_target_feature)]" ""
  '';

  meta = {
    inherit maintainers;
    description = "A median filter for TBCs that don't have VBI frame numbers, such as outputs of vhs-decode and cvbs-decode.";
    homepage = "https://github.com/namazso/tbc-raw-stack";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
