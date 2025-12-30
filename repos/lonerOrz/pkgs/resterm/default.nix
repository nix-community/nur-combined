{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "resterm";
  version = "0.13.6";

  src = fetchFromGitHub {
    owner = "unkn0wn-root";
    repo = "resterm";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-8SijpBkg46/5Hcmhr1BoWvri0XKKk16D5G1jJfAzy88=";
  };

  vendorHash = "sha256-Kj60MkxqRYORANalbJnjgtHMDgxOUOeaF1opqcYnVww=";

  subPackages = [ "cmd/resterm" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.version}"
    "-X main.date=1970-01-01_00:00:00_UTC"
  ];

  meta = {
    description = "Terminal-based REST client";
    homepage = "https://github.com/unkn0wn-root/resterm";
    mainProgram = "resterm";
    license = lib.licenses.asl20;
    platforms = with lib.platforms; linux ++ darwin;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
