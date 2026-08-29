final: prev: {
  yt-dlp-nightly = prev.yt-dlp.overrideAttrs (
    finalAttrs: previousAttrs: {
      pname = "yt-dlp-nightly";
      version = "2026.08.19-unstable-2026-08-27";

      src = prev.fetchFromGitHub {
        inherit (previousAttrs.src) owner repo;
        rev = "8377aa9555c308ca95630a28c1f91decd6c2235a";
        hash = "sha256-VfLs6zHF6yLWG21vgvCz01AA8jJMLg+Ap9i4PH6nJic=";
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
