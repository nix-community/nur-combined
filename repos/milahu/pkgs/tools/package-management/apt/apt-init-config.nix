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
}
