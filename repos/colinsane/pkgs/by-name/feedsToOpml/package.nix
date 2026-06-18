{
  buildPackages,
  lib,
  stdenv,
}:
let
  feeds-to-opml = buildPackages.static-nix-shell.mkPython3 {
    pname = "feeds-to-opml";
    srcRoot = ./.;
  };
  formatArgs = formats: lib.escapeShellArgs (lib.concatMap (format: [ "--format" format ]) formats);
in
{ feeds, formats ? [], name ? "feeds.opml" }:
stdenv.mkDerivation {
  inherit name;

  nativeBuildInputs = [ feeds-to-opml ];

  passAsFile = [ "feedsJson" ];
  feedsJson = builtins.toJSON feeds;

  buildCommand = ''
    feeds-to-opml ${formatArgs formats} "$feedsJsonPath" > "$out"
  '';

  passthru = {
    inherit feeds-to-opml;
  };
}
