{
  lib,
  clangStdenv,
  fetchFromGitHub,
  fetchpatch,
  Foundation,
  IOBluetooth,
}:
clangStdenv.mkDerivation rec {
  pname = "blueutil";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "toy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-dxsgMwgBImMxMMD+atgGakX3J9YMO2g3Yjl5zOJ8PW0=";
  };
  patches = [
    (fetchpatch {
      name = "fix-inquiry.patch";
      url = "https://patch-diff.githubusercontent.com/raw/toy/blueutil/pull/66.patch";
      sha256 = "sha256-oGxqJpnepM9C3YOKLOMbhq7cReUQ8Vlk+SxPRRmTQvU=";
    })
  ];

  buildInputs = [Foundation IOBluetooth];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wall"
    "-Wextra"
    "-Werror"
    "-mmacosx-version-min=10.9"
    "-framework Foundation"
    "-framework IOBluetooth"
  ];

  installPhase = ''
    install -Dm755 blueutil $out/bin/blueutil
  '';

  meta = with lib; {
    description = "blueutil";
    homepage = "https://github.com/toy/blueutil";
    changelog = "https://github.com/toy/blueutil/releases/tag/${version}";
    license = licenses.mit;
    maintainers = [maintainers.jpts];
    platforms = platforms.darwin;
  };
}
