{
  # keep-sorted start
  lib,
  package,
  runCommand,
  # keep-sorted end
}: let
  components = [
    # keep-sorted start
    package
    package.client
    package.render
    package.server
    # keep-sorted end
  ];
in
  runCommand "albedo-license-notices" {} ''
    ${lib.concatMapStringsSep "\n" (component: ''
        doc=${component}/share/doc/${component.pname}
        test "${component.meta.license.spdxId}" = "MPL-2.0"
        test "$(readlink "$doc/source")" = "${package.src}"
        test -f "$doc/source/gleam.toml"
        test -f "$doc/source/cli/go.mod"
        test -f "$doc/source/native/render/Cargo.lock"
        cmp "$doc/LICENSE" "${package.src}/LICENSE"
        cmp "$doc/THIRD_PARTY_NOTICES.md" "${package.src}/THIRD_PARTY_NOTICES.md"
        cmp "$doc/JetBrainsMono-OFL.txt" "${package.src}/native/render/fonts/JetBrainsMono-OFL.txt"
        grep -F "${package.src.rev}" "$doc/SOURCE.md"
        grep -F "${package.src}" "$doc/SOURCE.md"
      '')
      components}
    ${lib.concatMapStringsSep "\n" (component: ''
      test -d ${component}/share/doc/${component.pname}/dependencies
      test -n "$(find ${component}/share/doc/${component.pname}/dependencies -type f -print -quit)"
    '') [package.client package.render package.server]}
    touch $out
  ''
