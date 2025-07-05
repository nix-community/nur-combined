{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "waylrc";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "hafeoz";
    repo = "waylrc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VvGgrnlEIf3FJEk4e8v07QA6lHCaKF5pkJ3QszyObg4=";
  };

  patches = [ ./001-fix-player-rate.patch ];

  useFetchCargoVendor = true;

  cargoHash = "sha256-vCBwPhaSYbTvpus0ZbQplbsWIzVt8SqkauXh1lneRgw=";

  meta = {
    description = "An addon for waybar to display lyrics";
    homepage = "https://github.com/hafeoz/waylrc";
    license = with lib.licenses; [
      bsd0
      cc0
      wtfpl
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ definfo ];
  };
})
