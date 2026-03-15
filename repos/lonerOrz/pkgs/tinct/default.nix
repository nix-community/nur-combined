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
    rev = "5c20fb335fc216fc1373a0c5dddd575b675c9929";
    hash = "sha256-wF+Md+0UUTDHAmaoRzHQgwyyQN4/cH8qPCoPBFMSd9A=";
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
