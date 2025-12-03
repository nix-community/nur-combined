{ fetchurl, linkFarmFromDrvs }:
let
  videos = {
    hq = fetchurl {
      name = "showcase-hq.webm";
      url = "https://a.ocv.me/pub/demo/showcase-hq.webm";
      hash = "sha256-KbQusU3jr0Qe3zOD3VfCO8ae6QWQbUfWr7xU9VXP0w4=";
    };
    lq = fetchurl {
      name = "showcase-lq.mp4";
      url = "https://a.ocv.me/pub/demo/showcase-lq.mp4";
      hash = "sha256-dGs89nLusRnQWnwrZeh4UuTdCf2mIZdfxzB0TB4D4Dk=";
    };
    subs = fetchurl {
      name = "showcase-subs.mkv";
      url = "https://a.ocv.me/pub/demo/showcase-subs.mkv";
      hash = "sha256-wtrMiEpfG3yRGlBeWg29s21nNzlPUf6yATjAvUIjhoM=";
    };
  };
in
(linkFarmFromDrvs "copyparty-showcase-videos" (builtins.attrValues videos)).overrideAttrs (old: {
  passthru = (old.passthru or { }) // {
    inherit (videos) hq lq subs;
  };
})
