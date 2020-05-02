{ buildEnv, writeShellScriptBin }:

packages:

let
  profile = buildEnv {
    name = "user-environment";
    
    paths = packages;
  };

  command = {
    shell = ''
    nix-shell -p ${profile}
    '';

    test = ''
    nix-env --set ${profile}
    '';

    switch = ''
    echo "Switching to read-only profile"
    nix-env --switch-profile ${profile}
    '';

    reset = ''
    if [ -d "/nix/var/nix/profiles/per-user/$USER/profile/" ]; then
      echo "Resetting profile to /nix/var/nix/profiles/per-user/$USER/profile/"
      nix-env --switch-profile "/nix/var/nix/profiles/per-user/$USER/profile/"
    else
      echo "Couldn't find a per-user profile for $USER"
      echo "Resetting profile to /nix/var/nix/profiles/default/"
      nix-env --switch-profile "/nix/var/nix/profiles/default/"
    fi
    '';

    help = ''
    echo "$0 [shell|test|switch|reset]"
    '';
  };

in writeShellScriptBin "switch-to-environment" ''
case $1 in
  "shell")
  ${command.shell}
  ;;

  "test")
  ${command.test}
  ;;

  "switch")
  ${command.switch}
  ;;

  "reset")
  ${command.reset}
  ;;

  *)
  ${command.help}
  ;;
esac
''
