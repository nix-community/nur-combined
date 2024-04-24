{ lib
, clangStdenv
, fetchFromGitHub
, fetchpatch
, Foundation
, IOBluetooth
,
}:
clangStdenv.mkDerivation rec {
  pname = "blueutil";
  version = "2.9.1post";

  src = fetchFromGitHub {
    owner = "toy";
    repo = pname;
    #rev = "v${version}";
    rev = "dfe7fb2e0e11e53b2288e391c86874618d3ce185";
    sha256 = "sha256-6DKuWc4GhXtRfUSi+EcvJfzO8TaywRXpoLIEGWyz7VQ=";
  };
  patches = [
    (fetchpatch {
      name = "fix-inquiry.patch";
      url = "https://patch-diff.githubusercontent.com/raw/toy/blueutil/pull/66.patch";
      sha256 = "sha256-S97bnuFQah8zTIETFQQ4+i2S8PKYiJhEe249QnDeGdw=";
    })
  ];

  preferLocalBuild = true;

  buildInputs = [ Foundation IOBluetooth ];

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
    maintainers = [ maintainers.jpts ];
    platforms = platforms.darwin;
  };
}
