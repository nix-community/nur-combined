{ lib, buildGoModule, fetchFromGitHub, fetchpatch }:
buildGoModule rec {
  pname = "woodpecker-plugin-git";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "woodpecker-ci";
    repo = "plugin-git";
    rev = "v${version}";
    hash = "sha256-KU/A3V7KS8R1nAZoJJwkDc9C8y3t148kUzGnkeYtFjs=";
  };

  vendorHash = "sha256-63Ly/9yIJu2K/DwOfGs9pYU3fokbs2senZkl3MJ1UIY=";

  patches = [
    # https://github.com/woodpecker-ci/plugin-git/pull/67
    (fetchpatch {
      name = "do-not-overwrite-command-env.patch";
      url = "https://github.com/woodpecker-ci/plugin-git/commit/970cc63a9b212872deac565c6292feb3f4cf4b51.patch";
      hash = "sha256-izu0X7j+OyNbrOkksf+7VF3KiKVylVv2o00xaX/b1Rg=";
    })
  ];

  CGO_ENABLED = "0";

  # Checks fail because they require network access.
  doCheck = false;

  meta = with lib; {
    description = "Woodpecker plugin for cloning Git repositories.";
    homepage = "https://woodpecker-ci.org/";
    license = licenses.asl20;
    mainProgram = "pluging-git";
    maintainers = with maintainers; [ thehedgeh0g ];
    platforms = platforms.all;
  };
}
