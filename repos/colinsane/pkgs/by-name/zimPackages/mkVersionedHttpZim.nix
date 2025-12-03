# primary use case here is wikipedia.
# see list of wikipedia mirrors, which mostly include the .zim files:
# - <https://dumps.wikimedia.org/backup-index.html>
{
  directoryListingUpdater,
  fetchurl,
  stdenvNoCC,
}:
{
  pname,
  version,
  owner ? null,  #< same meaning as in e.g. `fetchFromGitHub`
  hash ? "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
}@args:
let
  tail = "${pname}_${version}.zim";
  prefix = if owner != null then "${owner}/" else "";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchurl {
    urls = [
      "https://download.kiwix.org/zim/${prefix}${tail}"
      "https://dumps.wikimedia.org/other/kiwix/zim/${prefix}${tail}"
      "https://mirror.accum.se/mirror/wikimedia.org/other/kiwix/zim/${prefix}${tail}"
      "https://mirror.download.kiwix.org/zim/.hidden/${prefix}${tail}"
    ];
    inherit hash;
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/zim
    ln -s ${finalAttrs.src} $out/share/zim/${pname}.zim

    runHook postInstall
  '';

  passthru.zimPath = "${finalAttrs.finalPackage}/share/zim/${pname}.zim";

  passthru.updateScript = directoryListingUpdater {
    url = "https://download.kiwix.org/zim/${prefix}";
  };
  # required so that directoryListingUpdater can know in which file the `version` variable can be updated in.
  passthru.meta.position = let
    position = builtins.unsafeGetAttrPos "version" args;
  in
    "${position.file}:${toString position.line}";
})
