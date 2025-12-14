{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "TODO";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "TODO";
    repo = "TODO";
    rev = "v${version}";
    hash = "sha256-TODO";
  };

  nativeBuildInputs = [
  ];

  buildInputs = [
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "TODO (don't end in period)";
    homepage = "TODO";
    license = licenses.TODO;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}
