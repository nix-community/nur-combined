{ ... }: {
  perSystem = { pkgs, ... }: {
    legacyPackages.alwaysFail = pkgs.runCommand "always-fail" { } ''
      echo "I am a silly derivation"
      echo "My only purpose in life is to fail"
      echo "how depressing is that?"
      echo
      echo "heres some text on stderr just in case" >&2
      exit 1
    '';
  };
}
