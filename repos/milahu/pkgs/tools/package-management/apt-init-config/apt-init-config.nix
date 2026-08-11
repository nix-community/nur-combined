{ lib
, writeShellApplication
, gnupg
#, gawk
}:

writeShellApplication {
  name = "apt-init-config";

  runtimeInputs = [
    gnupg
    #gawk # awk is not used
  ];

  text = builtins.readFile ./apt-init-config.sh;

  # disable shellcheck
  checkPhase = "";

  meta = with lib; {
    description = ''init config files for apt so you can run "apt update"'';
    license = licenses.mit;
  };
}
