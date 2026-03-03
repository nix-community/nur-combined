{
  meson,
  ninja,
  fetchFromGitHub,
  misrc-tools,
  hsdaoh,
  soxr,
  ...
}:

let
  pname = "misrc-tools-unstable";
  version = "0.5.1-unstable-2026-01-05";

  rev = "40a934ea2a0e29b652f8627b2a75d6dbf8a0f0d2";
  hash = "sha256-v/U+TbiFmc5KPz07VhrSDqukpDXVl3mV3Ayyf5Jjb54=";
in
(misrc-tools.override { inherit hsdaoh meson; }).overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      inherit (prevAttrs.src) owner repo sparseCheckout;
    };

    # CMake only included so Meson can locate hsdaoh
    dontUseCmakeConfigure = true;

    nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
      meson
      ninja
    ];

    buildInputs = prevAttrs.buildInputs ++ [
      soxr
    ];
  }
)
