{ callPackage }:

{
  de-ru = callPackage ./base.nix {
    lang = "de-ru";
    version = "2022-05-20";
    hash = "sha256-v3Uz+R/+MIr3MCyKNOrrkPuHYJDJEQggNbEMSliQbJs=";
  };

  en-ru = callPackage ./base.nix {
    lang = "en-ru";
    version = "2022-05-18";
    hash = "sha256-oLazcOnbSKHV4JbD3h9uWAGzaQD1BpY2mey27UH1nCQ=";
  };

  fi-ru = callPackage ./base.nix {
    lang = "fi-ru";
    version = "2022-05-16";
    hash = "sha256-lAB9umzqJOa/qLj37qR4GrEqfF70wQ719ddje/CWRrw=";
  };

  ru-be = callPackage ./base.nix {
    lang = "ru-be";
    version = "2022-05-07";
    hash = "sha256-RkWWO7e0hPSoSzutDfWHFm6OyZHL2yCACyfxHqqDvz0=";
  };

  ru-de = callPackage ./base.nix {
    lang = "ru-de";
    version = "2022-05-07";
    hash = "sha256-QPV6NhDipfLA2MKaVx+HQT61xjxzAPlpT1mWujMCjbE=";
  };

  ru-en = callPackage ./base.nix {
    lang = "ru-en";
    version = "2022-05-07";
    hash = "sha256-smpc3SCtZVbhC8K3fs02Gtonr2pICYMdCmljK4ymM7g=";
  };

  ru-eo = callPackage ./base.nix {
    lang = "ru-eo";
    version = "2022-05-07";
    hash = "sha256-gAyTjNGFalNlBh3N9XRseEU/kPov1nbbXXBVr6WtioY=";
  };

  ru-fi = callPackage ./base.nix {
    lang = "ru-fi";
    version = "2022-05-07";
    hash = "sha256-y1ISzpTKxtYRGF57McuAHLXZvWYCIVvtK0hjOls+NJI=";
  };

  ru-sv = callPackage ./base.nix {
    lang = "ru-sv";
    version = "2022-05-07";
    hash = "sha256-iPtV11QN5wyhKULJRxk9kPJckN2uT4vqDfrseqDbTMU=";
  };

  ru-uk = callPackage ./base.nix {
    lang = "ru-uk";
    version = "2022-05-07";
    hash = "sha256-2bNxHgLfqR7vZYUnhjMJ5FJ9mU9zHdcc4LSTqN9ANNM=";
  };
}
