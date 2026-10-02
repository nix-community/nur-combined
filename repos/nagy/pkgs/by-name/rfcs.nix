{
  lib,
  rsync,
  stdenvNoCC,
  symlinkJoin,
}:

let
  # Fetch RFC texts in bulk over rsync from the RFC editor, as a flat
  # directory of txt files.
  #
  # The 4-digit RFC space (rfc0001.txt .. rfc9999.txt) is permanently
  # frozen: every future RFC is 5 digits, so a 4-digit include pattern
  # yields a set that can never change and thus never invalidates its hash.
  fetchRFCTexts =
    {
      name,
      include, # rsync include patterns, e.g. [ "rfc[0-9][0-9][0-9][0-9].txt" ]
      hash,
    }:
    stdenvNoCC.mkDerivation {
      inherit name;
      dontUnpack = true;
      dontBuild = true;

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = hash;

      nativeBuildInputs = [ rsync ];

      installPhase = ''
        runHook preInstall

        mkdir $out
        rsync -rt \
          rsync.rfc-editor.org::rfcs-text-only/ \
          ${lib.concatMapStringsSep " \\\n          " (pattern: "--include='${pattern}'") include} \
          --exclude='*' \
          $out/

        runHook postInstall
      '';
    };

  # The 4-digit RFC space (RFC 1-9999) is frozen forever; publishing new
  # RFCs never touches this set, so this hash can never change.
  stable = fetchRFCTexts {
    name = "rfcs-stable";
    include = [ "rfc[0-9][0-9][0-9][0-9].txt" ];
    hash = "sha256-d01MUxsQSIg0K+7TCWS+EKLcjoHEXQ1I+6/WH7PbjZU=";
  };

  # RFC 10000 and up. Explicitly enumerated so that publishing new RFCs
  # does not invalidate the hash; nonexistent numbers are skipped by rsync.
  # Bump `last` (and the hash) to extend the snapshot deliberately.
  last = 10052;
  latest = fetchRFCTexts {
    name = "rfcs-latest";
    include = map (n: "rfc${toString n}.txt") (lib.range 10000 last);
    hash = "sha256-cngWXUNScjFaGpxDK5iQYLvBLSY9FpClZULmCw8XWuA=";
  };
in
symlinkJoin {
  name = "rfcs";
  paths = [
    stable
    latest
  ];
  meta = {
    description = "The complete set of IETF RFC texts (RFC 1-${toString last})";
    license = lib.licenses.unfreeRedistributable;
    platforms = lib.platforms.unix;
  };
  postBuild = ''
    mkdir -p $out/share/rfc
    mv $out/*.txt $out/share/rfc/
  '';
}
