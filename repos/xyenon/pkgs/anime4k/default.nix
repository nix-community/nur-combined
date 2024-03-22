{ lib, stdenvNoCC, fetchzip, isHighEnd ? false }:

let
  endLevel = if isHighEnd then "High" else "Low";
in
stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "Anime4K";
  version = "4.0.1";

  src = fetchzip {
    url = "https://github.com/Tama47/Anime4K/releases/download/v${version}/GLSL_Mac_Linux_${endLevel}-end.zip";
    hash =
      if isHighEnd then "sha256-Ah9fnVCDsliUzbCkKFcnWjLqG0y5DYlXJkZAz/H/oLQ="
      else "sha256-z4avJq7+JnTi+pf6mW5qn7zMxkTaplYq/3t4RU3vjOw=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out/

    runHook postInstall
  '';

  passthru.mpv = with builtins; with lib;
    let
      inherit (finalAttrs) finalPackage;

      inputConfLines = splitString "\n" (readFile "${finalPackage}/input.conf");
      mpvConfLines = splitString "\n" (readFile "${finalPackage}/mpv.conf");

      inputConfToNix = (line:
        let splited = lib.splitString " " line; in
        {
          name = head splited;
          value = replaceStrings [ "~~" ] [ "${finalPackage}" ]
            (lib.concatStringsSep " " (tail splited));
        }
      );
      mpvConfToNix = (line:
        let splited = lib.splitString "=" line; in
        {
          name = head splited;
          value = replaceStrings [ "~~" ] [ "${finalPackage}" ]
            (removeSuffix "\"" (removePrefix "\""
              (lib.concatStringsSep "=" (tail splited))
            ));
        }
      );

      inputConf = filterAttrs (n: v: n != "") (listToAttrs (map
        (line: inputConfToNix line)
        (filter (line: ! hasPrefix "#" line) inputConfLines)
      ));
      mpvConf = filterAttrs (n: v: n != "") (listToAttrs (map
        (line: mpvConfToNix line)
        (filter (line: ! hasPrefix "#" line) mpvConfLines)
      ));
    in
    {
      bindings = inputConf;
      config = mpvConf;
    };

  meta = with lib; {
    description = "A High-Quality Real Time Upscaler for Anime Video";
    homepage = "https://github.com/Tama47/Anime4K";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
})
