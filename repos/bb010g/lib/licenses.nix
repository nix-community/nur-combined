{ lib, libSuper }:

let
  spdx = lic: lic // {
    url = "http://spdx.org/licenses/${lic.spdxId}.html";
  };

  # lib imports {{{1
  inherit (lib.attrsets) #{{{2
    mapAttrs
  ;
  # no self-imports {{{1
  #}}}1
in mapAttrs (n: v: v // { shortName = n; }) {
  /* License identifiers from spdx.org where possible.
   * If you cannot find your license here or in nixpkgs/lib/licenses.nix, then
   * look for a similar license or add it to this list. The URL mentioned above
   * is a good source for inspiration.
   */

  bsdOriginalUC = spdx {
    spdxId = "BSD-4-Clause-UC";
    fullName = ''BSD-4-Clause (University of California-Specific)'';
  };

  caldera = spdx {
    spdxId = "Caldera";
    fullName = "Caldera License";
  };

  ccdl10 = spdx {
    spdxId = "CCDL-1.0";
    fullName = "Common Development and Distribution License 1.0";
  };

  ccdl11 = spdx {
    spdxId = "CCDL-1.1";
    fullName = "Common Development and Distribution License 1.1";
  };

  infozip = spdx {
    spdxId = "Info-ZIP";
    fullName = "Info-ZIP License";
  };
}
# vim:fdm=marker:fdl=1
