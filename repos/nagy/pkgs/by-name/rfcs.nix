{
  stdenv,
  symlinkJoin,
  callPackage,
}:

let
  inherit (callPackage ../../lib/rfc.nix { }) fetchRFCBulk;
in
stdenv.mkDerivation {
  name = "rfcs";
  src = symlinkJoin {
    name = "rfcs";
    paths = [
      (fetchRFCBulk {
        range = "0001-0500";
        hash = "sha256-IWWyhw4qHtn0uPhVtUha+CVqw2ODL5uCOnuPiqKAQN8=";
      })
      (fetchRFCBulk {
        range = "0501-1000";
        hash = "sha256-oXQFaGWfpGz82ajK/lJ8tM/IcMFOx0dLhp8VqF7H3Ss=";
      })
      (fetchRFCBulk {
        range = "1001-1500";
        hash = "sha256-gu8Y+qwj+rhJB0zViMCE2BzgGEl0i95dbkPWJ/yHGpY=";
      })
      (fetchRFCBulk {
        range = "1501-2000";
        hash = "sha256-bfqBd8KO7AnvK4WKGw/GPg4XWdqq1fKq/qlAszv6dNU=";
      })
      (fetchRFCBulk {
        range = "2001-2500";
        hash = "sha256-FcYx+QcCFjUkA9k89W+nRygZySoaiIOg/HR5XtauVEc=";
      })
      (fetchRFCBulk {
        range = "2501-3000";
        hash = "sha256-ivngywGT5PMj6yQw3llKIkVEZixup7jtpxNzb7oZ/N8=";
      })
      (fetchRFCBulk {
        range = "3001-3500";
        hash = "sha256-efmPFtMBOhBFUjlNYODRY80dGh65Ar8LZjbJAUhrXyQ=";
      })
      (fetchRFCBulk {
        range = "3501-4000";
        hash = "sha256-SH1S7qAGx3RpI4q0SQfsqnoLVzgyxkBVBQJcAUfGTeQ=";
      })
      (fetchRFCBulk {
        range = "4001-4500";
        hash = "sha256-l61Y8ONNwlJ6YxxEjUellN3froh0DMkIBqthy5NTrw0=";
      })
      (fetchRFCBulk {
        range = "4501-5000";
        hash = "sha256-ROeg1yyYxwih3ew80UYMSFCyRIpUUUEm4XBywRbRP5M=";
      })
      (fetchRFCBulk {
        range = "5001-5500";
        hash = "sha256-xEMH5x9lzlZ18x/6NIhrXZjoACFY5EnQ5AXFIPqos3Y=";
      })
      (fetchRFCBulk {
        range = "5501-6000";
        hash = "sha256-pbX5rtABeJp7XkNj44sFgctY12QpkkN2SKXXersbjGo=";
      })
      (fetchRFCBulk {
        range = "6001-6500";
        hash = "sha256-z8dHZoACvzMSrBbaSnZsPeBuDlQvFLixR0ho4cS5who=";
      })
      (fetchRFCBulk {
        range = "6501-7000";
        hash = "sha256-FJRhoiHfbqSyM4CJd0qFPJa2n+Zs52CnyY1BlwV24WU=";
      })
      (fetchRFCBulk {
        range = "7001-7500";
        hash = "sha256-m4h7segOsuhGKxjY/pBJpHKGUZZhIB5CpTbGZ/lw8bU=";
      })
      (fetchRFCBulk {
        range = "7501-8000";
        hash = "sha256-OIFl7kXOiFZxKCp779vzr/RLN93nMpqAgdSCd8A6lVk=";
      })
      (fetchRFCBulk {
        range = "8001-8500";
        hash = "sha256-MWN0gQke+zes2o9JYgiGQAtYMaF1E70aupvVlsQ+YRg=";
      })
      (fetchRFCBulk {
        range = "8501-9000";
        hash = "sha256-Gjae6Pprj/AOiAfNQdof7pw5zlo2HAmI1l9Rqzwf1sA=";
      })
      (fetchRFCBulk {
        range = "9001-9500";
        hash = "sha256-XPIFvgY+xQ4OrYmWkWoFcRMMp8MAY0YVXGIc7qVnqjo=";
      })
      (fetchRFCBulk {
        range = "9501-latest";
        # even though we download the "latest" file, after removing files, that
        # we dont know. we should end up with the same hash regardless of
        # upstream file changes.
        postFetch = ''
          find -not -regex ".*/rfc95[0-9][0-9][0-9]\\.txt" -delete
        '';
        hash = "sha256-Yu1pwSJKp2PB38xVXrxlcbm5eS9zf0Fj/ZUVONef2tY=";
      })
    ];
  };
  buildPhase = ''
    runHook preBuild

    install -Dt $out/share/rfc/ *.txt

    runHook postBuild
  '';
}
