{ lib, bundlerEnv, bundlerUpdateScript, ruby }:

bundlerEnv {
  pname = "omnibus";
  version = "9.0.23";

  inherit ruby;
  gemdir = ./.;

  passthru.updateScript = bundlerUpdateScript "omnibus";

  meta = with lib; {
    description = "Easily create full-stack installers for your project across a variety of platforms";
    changelog = "https://github.com/chef/omnibus/blob/${version}/CHANGELOG.md";
    homepage = "https://github.com/chef/omnibus";
    license = licenses.asl20;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
