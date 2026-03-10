{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "tinct";
  version = "0.1.0";

  # https://github.com/lonerOrz/tinct
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "tinct";
    rev = "d1769ea8974b1f4ea2656393cd354dbb736aef6e";
    hash = "sha256-n3+touFYeLtctxXvZtbt6m6nvQ35EmoUqlCckKHPyC8=";
  };

  cargoHash = "sha256-fN/CykGctlGmN2JfuIj5/KYOSuUbpxrNkU0ucvsWRM0=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Theme injector tool that applies Material Design 3 color palettes to various configuration files";
    homepage = "https://github.com/lonerOrz/tinct";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "tinct";
  };
})
