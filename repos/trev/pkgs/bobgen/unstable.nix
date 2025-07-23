{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.38.0-unstable-2025-07-22";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "08202428a120d26097136c41841fc636afa236a1";
    hash = "sha256-3/JEfbqOAJuvjrsJHKclLl9c0zMy5M+0lwG+3c0nXPY=";
  };

  vendorHash = "sha256-tCkGffOdIm8lP/iXDji7OFVTztW9Dd1cqx5xsE2QYtU=";

  passthru = {
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "--version=branch=main"
        "${final.pname}.unstable"
      ];
    });
  };

  meta =
    prev.meta
    // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/stephenafamo/bob/commits/${final.src.rev}/";
    };
})
