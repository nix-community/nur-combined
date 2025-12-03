{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  fusepy,
  ratarmountcore,
  fsspec,
  zstd,
  pytestCheckHook,
  callPackage,
}:

buildPythonPackage rec {
  pname = "ratarmount";

  inherit (ratarmountcore) version src disabled;

  propagatedBuildInputs = [
    ratarmountcore
  ];

  # WONTFIX? many tests fail
  # 14 failed, 439 passed, 2 skipped in 452.81s (0:07:32)
  # https://discourse.nixos.org/t/using-fuse-inside-nix-derivation/8534
  /*
  nativeCheckInputs = [
    pytestCheckHook
    zstandard
    zstd
  ];
  */

  passthru = {
    test = callPackage ./test.nix { };
  };

  meta = with lib; {
    description = "Mounts archives as read-only file systems by way of indexing";
    homepage = "https://github.com/mxmlnkn/ratarmount";
    license = licenses.mit;
    maintainers = with lib.maintainers; [ mxmlnkn ];
    platforms = platforms.all;
  };
}
