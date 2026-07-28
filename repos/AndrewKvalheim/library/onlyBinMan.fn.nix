{ lib

  # Dependencies
, onlyBin
}:

let
  inherit (lib) getMan;
in
package: (onlyBin package).overrideAttrs (attrs: {
  name = attrs.name + "-man";
  buildCommand = attrs.buildCommand + ''
    if [[ -d '${getMan package}/share/man' ]]; then
      mkdir "$out/share"
      ln --symbolic '${getMan package}/share/man' "$out/share/man"
    fi
  '';
})
