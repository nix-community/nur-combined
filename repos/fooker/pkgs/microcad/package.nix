{
  lib,
  fetchFromGitea,
  rustPlatform,
  cmake,
  ninja,
  git,
  ...
}:

rustPlatform.buildRustPackage (finalPackage: {
  pname = "microcad";
  version = "0.2.18";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "microcad";
    repo = "microcad";
    rev = "refs/tags/v${finalPackage.version}";
    hash = "sha256-FNjGXYUui50S2BTutRQlLljo6afsTeDQ5cxtobxlJy4=";
  };

  cargoHash = "sha256-B/ylabtSQB3dyAMZkYEAL8bXBirhdCrzmDqeyhSn8eQ=";

  nativeBuildInputs = [
    cmake
    ninja
    git
  ];

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  meta = {
    description = "Modern programming language for CAD";
    homepage = "https://microcad.xyz";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fooker ];
  };
})

