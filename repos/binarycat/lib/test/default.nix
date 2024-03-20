{ pkgs, lib }:
let
  inherit (builtins) trace tryEval;
  inherit (pkgs.lib) recurseIntoAttrs;
  inherit (pkgs.lib.lists) flatten;
  inherit (pkgs.lib.attrsets) isDerivation foldlAttrs;
  inherit (pkgs.lib.strings) escapeURL;
  inherit (lib.attrsets) withPrefix;
in rec {
  getMetaUrls = pkg:
    if (tryEval pkg).success
    then
      (if isDerivation pkg
       then flatten
         [ pkg.meta.homepage or [ ]
           pkg.meta.downloadPage or [ ]
           pkg.meta.changelog or [ ] ]
       else [ ]) ++
      (if (pkg).recurseForDerivations or false
       then foldlAttrs (acc: k: v: acc ++ getMetaUrls v) [ ] pkg
       else [ ])
    else [ ];

  # needs to have url in package name otherwise it gets deduplicated by linkFarmFromDrvs
  urlExists = u: pkgs.runCommand "test-url-availible-${u}"
    {
      nativeBuildInputs = with pkgs; [ curl ];
      __noChroot = true;
    } ''
      echo -e "checking if url exists:\t${u}"
      # disable ssl check because nix hides certs
      curl --insecure --fail -ILXHEAD ${u}
      touch $out
  '';

  checkMetaUrls = pkg: pkgs.linkFarmFromDrvs "check-meta-urls"
    (map urlExists (let urls = getMetaUrls pkg; in trace "got urls: ${builtins.toJSON urls}" urls));

  # example usage: sudo nix-build --no-sandbox -E '(import ./. {}).lib.testers.checkMetaUrlsPkgPrefix "b"'
  checkMetaUrlsPkgPrefix = pre:
    checkMetaUrls (pkgs.lib.recurseIntoAttrs (withPrefix pre
      (pkgs)));
}
