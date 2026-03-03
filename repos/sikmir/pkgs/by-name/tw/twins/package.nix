{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitea,
}:

buildGoModule (finalAttrs: {
  pname = "twins";
  version = "1.0.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "tslocum";
    repo = "twins";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WV9OEiT/M5lCCTelc7vWoIkOt7SAAPnzuacNR08uCBQ=";
  };

  vendorHash = "sha256-/v7DXGOiL8jZtOnIx8R+gYmmayyuIvx8ahYSbRQjUAY=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Gemini server";
    homepage = "https://codeberg.org/tslocum/twins";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "twins";
  };
})
