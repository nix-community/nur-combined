{ lib, bundlerEnv, ruby, bundlerUpdateScript }:

bundlerEnv {
  inherit ruby;
  pname = "xcodeproj";
  gemdir = ./.;

  passthru.updateScript = bundlerUpdateScript "xcodeproj";

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ zachcoyle ];
  };
}
