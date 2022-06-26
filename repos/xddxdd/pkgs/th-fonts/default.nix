{ callPackage
, stdenvNoCC
, lib
, fetchurl
, ...
} @ args:

let
  font = callPackage ./font.nix;
in
{
  tshyn = font rec {
    pname = "TH-Tshyn";
    version = "3.0.0";
    sha256 = "0ml9v6lji3s8b4qrbzn5rkr3jxvnpc94188aibgi53am0zca3p1r";
  };
  hak = font rec {
    pname = "TH-Hak";
    version = "3.0.0";
    sha256 = "1j7pn2zp74x0qfzh48kc8mn8zk150xmgn9ahnk79j873nqbklwpp";
  };
  joeng = font rec {
    pname = "TH-Joeng";
    version = "3.0.0";
    sha256 = "0hrix06npd0fipf83vkhh53zn5dp3kpa7y6myy970qq93bckck8z";
  };
  khaai-t = font rec {
    pname = "TH-Khaai-T";
    version = "3.0.0";
    filename = "${pname}${version}";
    sha256 = "1s1spixf4rjsak33abdaw1f12nx0qq4gz0q97bjq957yv530d86s";
  };
  khaai-p = font rec {
    pname = "TH-Khaai-P";
    version = "3.0.0";
    filename = "${pname}${version}";
    sha256 = "096yi5ppiqsdfv7yhink51djzlfzhrs3wrzkd0n1xzqpqa7dk33s";
  };
  ming = font rec {
    pname = "TH-Ming";
    version = "3.0.0";
    sha256 = "1iywff4j93syihf2325anxxxyn25m2m83j72l0bhdr3ndm1m71ji";
  };
  sung-t = font rec {
    pname = "TH-Sung-T";
    version = "3.0.0";
    filename = "${pname}${version}";
    sha256 = "1bwbzjsnw74kllbfyig8cl1296sv1bwwrc6y1vf8q7xdx5f781z4";
  };
  sung-p = font rec {
    pname = "TH-Sung-P";
    version = "3.0.0";
    filename = "${pname}${version}";
    sha256 = "13bs263fhxgbbzr8ahbk0i0bhzb7pw0vjqasxnk224gx2s27qy2d";
  };
  sy = font rec {
    pname = "TH-Sy";
    version = "3.0.0";
    sha256 = "00fq55js5zdx58563c2a9iw67gx3k8rqcgwsbkj34q86g4c1khb6";
  };

  # TH-Feon isn't compressed
  feon = stdenvNoCC.mkDerivation rec {
    pname = "TH-Feon";
    version = "3.0.0";
    src = fetchurl {
      url = "https://backblaze.lantian.pub/TH-Feon.ttf";
      sha256 = "0wxjk92qz3zqdf8n7lqh13v17igphampmn6vmahb9x8572f0532g";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/fonts/opentype/
      cp ${src} $out/share/fonts/opentype/TH-Feon.ttf
    '';

    meta = with lib; {
      description = "${pname} font";
      homepage = "http://cheonhyeong.com/Simplified/download.html";
    };
  };
}
