final: prev: {
  yt-dlp-nightly = prev.yt-dlp.overrideAttrs (
    finalAttrs: previousAttrs: {
      pname = "yt-dlp-nightly";
      version = "2026.08.19-unstable-2026-08-19";

      src = prev.fetchFromGitHub {
        inherit (previousAttrs.src) owner repo;
        rev = "3a08beaf031ab68f966401ead017ac81fe8486cf";
        hash = "sha256-BM5ZeGTmHq+1xH6G/zsuCtjLgYgfRA11ya0zIHK5p4g=";
      };

      postPatch = ''
        version=${prev.lib.replaceString "-" "." finalAttrs.version}
        prefix=*unstable.
        version="''${version#$prefix}"
        python devscripts/update-version.py -c nightly -r RoGreat/nur-packages $version
      ''
      + previousAttrs.postPatch;
    }
  );
}
