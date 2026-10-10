{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../default.nix { inherit pkgs; }).changedetection-io,
}:
let
  reviewedSource = pkgs.fetchFromGitHub {
    owner = "dgtlmoon";
    repo = "changedetection.io";
    tag = "0.60.8";
    hash = "sha256-gbZEnSBRuLUexuNWNka6K/NY3mwy6Dujx3y/y+7fqaA=";
  };
  overridden = package.overrideAttrs {
    version = "test-version";
    __intentionallyOverridingVersion = true;
  };
  service =
    (import (pkgs.path + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        {
          services.changedetection-io = {
            enable = true;
            inherit package;
          };
        }
      ];
    }).config.systemd.services.changedetection-io;
in
assert package.src.tag == package.version;
assert overridden.src.tag == "test-version";
assert
  !pkgs.stdenv.hostPlatform.isLinux
  || pkgs.lib.hasInfix (builtins.unsafeDiscardStringContext "${package}/bin/changedetection.py") service.serviceConfig.ExecStart;
pkgs.runCommand "changedetection-io-dependency-check"
  {
    nativeBuildInputs = [ pkgs.diffutils ];
  }
  ''
    changed=0
    for file in requirements.txt setup.py; do
      diff -u --label "reviewed/$file" --label "upstream/$file" \
        ${reviewedSource}/"$file" ${package.src}/"$file" || changed=1
    done
    if [ "$changed" != 0 ]; then
      echo "Review upstream dependency changes, adjust the package, then update reviewedSource in tests/pkgs/changedetection-io.nix." >&2
      exit 1
    fi
    touch "$out"
  ''
