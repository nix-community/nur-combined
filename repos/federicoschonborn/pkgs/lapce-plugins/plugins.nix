{ lib, mkLapcePlugin }:

{
  "Azartiny" = lib.recurseIntoAttrs {
    "wild-pastel" = mkLapcePlugin {
      author = "Azartiny";
      name = "wild pastel";
      version = "0.1.1";
      hash = "sha256-yD2HirhGxl3DUzbED+w+4V3v6Y92ZifmyYVW/dC13AA=";
      wasm = false;
    };
  };

  "BillyDM" = lib.recurseIntoAttrs {
    "darcula" = mkLapcePlugin {
      author = "BillyDM";
      name = "darcula";
      version = "0.3.0";
      hash = "sha256-yJBmYBZYXpSMd25KpmovTay1p/teegwHxgqQ5FgWN0U=";
      wasm = false;
    };
  };

  "Catppuccin-Holdings" = lib.recurseIntoAttrs {
    "catppuccin" = mkLapcePlugin {
      author = "Catppuccin-Holdings";
      name = "catppuccin";
      version = "0.1.18";
      hash = "sha256-CMZez58yYmgC07MX4jw7s3fccCMK2WP51oII/7GmOBw=";
      wasm = false;
    };
  };

  "Codextor" = lib.recurseIntoAttrs {
    "material-theme" = mkLapcePlugin {
      author = "Codextor";
      name = "material-theme";
      version = "1.2.0";
      hash = "sha256-qHE80Ickzm6qZcuMVb91BIvsRT7sivz34uByILdf1iY=";
      wasm = false;
    };
  };

  "ConnorSMorrison" = lib.recurseIntoAttrs {
    "spaceduck" = mkLapcePlugin {
      author = "ConnorSMorrison";
      name = "spaceduck";
      version = "0.0.1";
      hash = "sha256-HjtzZSC161c9EH7sCogzphXMuH1VGTt1rODp0UC9Dh4=";
      wasm = false;
    };
  };

  "CroxxN" = lib.recurseIntoAttrs {
    "lapce-html" = mkLapcePlugin {
      author = "CroxxN";
      name = "lapce-html";
      version = "0.0.1";
      hash = "sha256-/uazWNQ7mDWPsCAffChz2xyYiJXmKksGkBNiqXKroHg=";
      wasm = true;
    };
  };

  "DissolveDZ" = lib.recurseIntoAttrs {
    "neonight" = mkLapcePlugin {
      author = "DissolveDZ";
      name = "neonight";
      version = "0.1.0";
      hash = "sha256-QKnf0zXbbLG8yTkGNJXoYemY521Fjr/hMTYSVYQywP0=";
      wasm = false;
    };
  };

  "GosainAmit" = lib.recurseIntoAttrs {
    "mukong-theme" = mkLapcePlugin {
      author = "GosainAmit";
      name = "mukong theme";
      version = "0.1.1";
      hash = "sha256-wcwJOHD+MzbFuTyk5Vkk1EMO0UsR+lecDXKlpVYT9gg=";
      wasm = false;
    };
  };

  "HTGAzureX1212" = lib.recurseIntoAttrs {
    "rs4lapce" = mkLapcePlugin {
      author = "HTGAzureX1212";
      name = "rs4lapce";
      version = "0.2.0";
      hash = "sha256-DzvI540fYBoiibdhZWlhbbxJJnN2z9NQSVLR06druCA=";
      wasm = true;
    };
  };

  "Hyduez" = lib.recurseIntoAttrs {
    "dou-lapcord" = mkLapcePlugin {
      author = "Hyduez";
      name = "dou-lapcord";
      version = "2.1.3";
      hash = "sha256-Rze956JhxnuArJIUjDplzT/k8ThxK/ESSpGBQqcPiC4=";
      wasm = true;
    };
    "dou.lapcord" = mkLapcePlugin {
      author = "Hyduez";
      name = "dou.lapcord";
      version = "2.0.1";
      hash = "sha256-jjtY9mKq5homhFZkw2XND5GGAxkH23HJZ4vaYHpHDvk=";
      wasm = true;
    };
  };

  "Incognitux" = lib.recurseIntoAttrs {
    "everblush" = mkLapcePlugin {
      author = "Incognitux";
      name = "everblush";
      version = "0.1.0";
      hash = "sha256-b2BCnJT6MAzZhpmcjtHaqLxjU8aw25FfyRy7w/o7NWI=";
      wasm = false;
    };
  };

  "ItzSwirlz" = lib.recurseIntoAttrs {
    "aura-theme" = mkLapcePlugin {
      author = "ItzSwirlz";
      name = "aura-theme";
      version = "0.1.0";
      hash = "sha256-n44Ap5s0tmM0Ouf0VUm8IMLOboayLSFnpps9jmUjoFU=";
      wasm = false;
    };
    "nord-theme" = mkLapcePlugin {
      author = "ItzSwirlz";
      name = "nord-theme";
      version = "0.1.1";
      hash = "sha256-9iCJQlhfhiPAyxp+duPRYbhKl5hmJP4V+xEgZ9BBBZA=";
      wasm = false;
    };
  };

  "Jalkhov" = lib.recurseIntoAttrs {
    "marge" = mkLapcePlugin {
      author = "Jalkhov";
      name = "marge";
      version = "0.1.0";
      hash = "sha256-5BlX4GeqDUdnPVqBjTIRCKaHw/LY9mefLghFKzoIIxs=";
      wasm = false;
    };
  };

  "JarWarren" = lib.recurseIntoAttrs {
    "xcodedark-theme" = mkLapcePlugin {
      author = "JarWarren";
      name = "xcodedark-theme";
      version = "0.1.1";
      hash = "sha256-4U/QhsTzQAJCqabdezbl36ivrd0+l4rxUPH2b0C/AJ0=";
      wasm = false;
    };
    "xcodelight-theme" = mkLapcePlugin {
      author = "JarWarren";
      name = "xcodelight-theme";
      version = "0.1.2";
      hash = "sha256-AiLxEJNLlrKiKcjyiGYSAlmktZUsYiPY1R2HnL56Ruk=";
      wasm = false;
    };
  };

  "KennanHunter" = lib.recurseIntoAttrs {
    "monokai" = mkLapcePlugin {
      author = "KennanHunter";
      name = "monokai";
      version = "0.1.0";
      hash = "sha256-2wQ7sFBxWXgFhxWN6xkSRpNag4iJCNtIhbIqm97LIAI=";
      wasm = false;
    };
  };

  "Lucas3oo" = lib.recurseIntoAttrs {
    "eclipse-theme" = mkLapcePlugin {
      author = "Lucas3oo";
      name = "eclipse-theme";
      version = "0.0.3";
      hash = "sha256-/CIXzGoudKs2fEumzBLlSppCx4edy42p0dQqm7I3ltc=";
      wasm = false;
    };
  };

  "MathiasPius" = lib.recurseIntoAttrs {
    "lapce-crates" = mkLapcePlugin {
      author = "MathiasPius";
      name = "lapce-crates";
      version = "0.1.0";
      hash = "sha256-tyUn0a1FoRlMRYFPfSy7FzP2FFZ52s197kAma2rpgXA=";
      wasm = true;
    };
  };

  "Mikastiv" = lib.recurseIntoAttrs {
    "ocean-space-refined" = mkLapcePlugin {
      author = "Mikastiv";
      name = "ocean-space-refined";
      version = "0.1.2";
      hash = "sha256-+n9Q+e9qzGOqH4hgyh5m09flCpcujhw/6osKdaAqWu8=";
      wasm = false;
    };
  };

  "MinusGix" = lib.recurseIntoAttrs {
    "aleph" = mkLapcePlugin {
      author = "MinusGix";
      name = "aleph";
      version = "0.3.2";
      hash = "sha256-ByXVdX0MVZJFN74uWecFgh/BZL6F90OeWdH75RAC17A=";
      wasm = false;
    };
    "dark-forest" = mkLapcePlugin {
      author = "MinusGix";
      name = "dark-forest";
      version = "0.1.1";
      hash = "sha256-hYcz54F8ryq5m9drLAvYDPOhbZpOFL0CkZuQeebU26w=";
      wasm = false;
    };
    "lapce-copilot" = mkLapcePlugin {
      author = "MinusGix";
      name = "lapce-copilot";
      version = "1.0.1";
      hash = "sha256-+p0BGte0R9cZPNUIkDpItC3s8YZA50bq53Ydjth6n0U=";
      wasm = true;
    };
  };

  "MrFoxPro" = lib.recurseIntoAttrs {
    "lapce-nix" = mkLapcePlugin {
      author = "MrFoxPro";
      name = "lapce-nix";
      version = "0.0.1";
      hash = "sha256-n+j8p6sB/Bxdp0iY6Gty9Zkpv9Rg34HjKsT1gUuGDzQ=";
      wasm = true;
    };
  };

  "NachiketNamjoshi" = lib.recurseIntoAttrs {
    "gruvbox" = mkLapcePlugin {
      author = "NachiketNamjoshi";
      name = "gruvbox";
      version = "0.2.0";
      hash = "sha256-k7/MylUTXhQtVKHweTAl1ddkUotStr7rdsmmwYKEZOA=";
      wasm = false;
    };
  };

  "Notiee" = lib.recurseIntoAttrs {
    "forest-night-theme" = mkLapcePlugin {
      author = "Notiee";
      name = "forest-night-theme";
      version = "0.1.1";
      hash = "sha256-G0/L20thvMn9fXBMp7VW5Ci0SJKDb2YNan2rtA4FBAw=";
      wasm = false;
    };
  };

  "SimY4" = lib.recurseIntoAttrs {
    "alabaster-theme" = mkLapcePlugin {
      author = "SimY4";
      name = "alabaster-theme";
      version = "0.1.0";
      hash = "sha256-J6OKBYixnNf/BBUlZvk14RZFDUgjA6SQ/GoJ5FJO4bs=";
      wasm = false;
    };
  };

  "Stanislav-Lapata" = lib.recurseIntoAttrs {
    "lapce-angular" = mkLapcePlugin {
      author = "Stanislav-Lapata";
      name = "lapce-angular";
      version = "0.1.0";
      hash = "sha256-0LgJZr/2FxxK9Ys3QXojhAYU3hnaZOzW0RgZvA3Pago=";
      wasm = true;
    };
    "lapce-solargraph" = mkLapcePlugin {
      author = "Stanislav-Lapata";
      name = "lapce-solargraph";
      version = "0.1.2";
      hash = "sha256-ogi8ZaMp0CYNUYFd91ykGsn/rEoTXSBgsZJni932p9I=";
      wasm = true;
    };
  };

  "Stepland" = lib.recurseIntoAttrs {
    "monokai-vscode" = mkLapcePlugin {
      author = "Stepland";
      name = "monokai-vscode";
      version = "1.0.0";
      hash = "sha256-NoalGt6R+gwPHTHEg35ppbM4u3aeyq9aaU6Mm2jwc78=";
      wasm = false;
    };
  };

  "ThePoultryMan" = lib.recurseIntoAttrs {
    "lapce-github-themes" = mkLapcePlugin {
      author = "ThePoultryMan";
      name = "lapce-github-themes";
      version = "0.1.0";
      hash = "sha256-8Bmxr7sKDiAVqqghJitoKtTRJJpWHT4RNRSeP1j9U6s=";
      wasm = false;
    };
  };

  "VarLad" = lib.recurseIntoAttrs {
    "lapce-julia-ls" = mkLapcePlugin {
      author = "VarLad";
      name = "lapce-julia-ls";
      version = "0.0.5";
      hash = "sha256-FGjDsNj4Z4q3GIwJysBgkE2ws/XQZYK2L7yMIuTkaUU=";
      wasm = true;
    };
  };

  "WalterOfNone" = lib.recurseIntoAttrs {
    "ayu" = mkLapcePlugin {
      author = "WalterOfNone";
      name = "ayu";
      version = "0.1.2";
      hash = "sha256-8m9joh8VTkd4fzNevFmZROsQ5Cl7si84oVQ01nTCjdo=";
      wasm = false;
    };
  };

  "X64D" = lib.recurseIntoAttrs {
    "lapce-tinymist" = mkLapcePlugin {
      author = "X64D";
      name = "lapce-tinymist";
      version = "0.0.1";
      hash = "sha256-iSudWviA2XX0yhbdq8UVyeWXLh9TCIAdRQwjGWrfD54=";
      wasm = true;
    };
  };

  "abreumatheus" = lib.recurseIntoAttrs {
    "lapce-pyright" = mkLapcePlugin {
      author = "abreumatheus";
      name = "lapce-pyright";
      version = "0.1.1";
      hash = "sha256-C1YOg6WcRcN7+br9eCiUzSQVAj/JloH9+fY9IME1bpg=";
      wasm = true;
    };
    "lapce-ruff-lsp" = mkLapcePlugin {
      author = "abreumatheus";
      name = "lapce-ruff-lsp";
      version = "0.1.1";
      hash = "sha256-ttYWC+GEQlFZR+Qu2rMLiKFDNsFeILRzDl6XQeiqqt0=";
      wasm = true;
    };
  };

  "ahmrz" = lib.recurseIntoAttrs {
    "aswad" = mkLapcePlugin {
      author = "ahmrz";
      name = "aswad";
      version = "0.3.0";
      hash = "sha256-E3CwLOOKkFBzbgFHq1ANs35vsbL3XkuZRZvDvEtZXDA=";
      wasm = false;
    };
  };

  "akhildevelops" = lib.recurseIntoAttrs {
    "lapce-python-nouse" = mkLapcePlugin {
      author = "akhildevelops";
      name = "lapce-python-nouse";
      version = "0.4.0";
      hash = "sha256-Acm9iMOMFCusvzY/BwIMxIFTwnD/EW3eomVrE7I6qdk=";
      wasm = true;
    };
  };

  "ayhon" = lib.recurseIntoAttrs {
    "adwaita" = mkLapcePlugin {
      author = "ayhon";
      name = "adwaita";
      version = "0.1.0";
      hash = "sha256-V6KKc506Iy+AyTbgUhcyoS/oRqWYK14FN+D0VenZuD4=";
      wasm = false;
    };
  };

  "brocococonut" = lib.recurseIntoAttrs {
    "lapce-svelte" = mkLapcePlugin {
      author = "brocococonut";
      name = "lapce-svelte";
      version = "0.1.0";
      hash = "sha256-XnvhI3FC3JpItPhF7cmpG6Hej/D1UZlW3xdbnz1cI0I=";
      wasm = true;
    };
  };

  "c-sleuth" = lib.recurseIntoAttrs {
    "bright-pastel-icons" = mkLapcePlugin {
      author = "c-sleuth";
      name = "bright-pastel-icons";
      version = "0.0.0";
      hash = "sha256-+v3cUgKrghxSjCNLgwuWRn/HSIhUu7ERhE8yIEyvz8A=";
      wasm = false;
    };
    "pastel-collection-lapce" = mkLapcePlugin {
      author = "c-sleuth";
      name = "pastel-collection-lapce";
      version = "0.1.0";
      hash = "sha256-wtODtc/oAxBB1wH5uQ4c/8g/Awa8kVDlvfxeRwcYUvs=";
      wasm = false;
    };
  };

  "d4rkr41n" = lib.recurseIntoAttrs {
    "dracula" = mkLapcePlugin {
      author = "d4rkr41n";
      name = "dracula";
      version = "0.1.0";
      hash = "sha256-25Suo8qjZjnZ2txsgLLokidZFZEYo7sjBL2ELYL87/Q=";
      wasm = false;
    };
  };

  "dajoha" = lib.recurseIntoAttrs {
    "lapce-php-intelephense" = mkLapcePlugin {
      author = "dajoha";
      name = "lapce-php-intelephense";
      version = "0.1.0";
      hash = "sha256-j3yaijcIbVx28kjHJQSEsTPlu3lgS0uomu9mfvy0/Qw=";
      wasm = true;
    };
  };

  "dyu" = lib.recurseIntoAttrs {
    "nordyu-theme" = mkLapcePlugin {
      author = "dyu";
      name = "nordyu-theme";
      version = "0.1.0";
      hash = "sha256-E+bP2ZlUcBZDmOK7vQSGuLMGV1pzl6Zt4jdTuwsI83A=";
      wasm = false;
    };
  };

  "dzhou121" = lib.recurseIntoAttrs {
    "lapce-lldb" = mkLapcePlugin {
      author = "dzhou121";
      name = "lapce-lldb";
      version = "0.1.1";
      hash = "sha256-pO1jjG6oOr1N7X/fmivJ3YnAjB/nSSbccMtuS92/y90=";
      wasm = true;
    };
    "lapce-rust" = mkLapcePlugin {
      author = "dzhou121";
      name = "lapce-rust";
      version = "0.3.2162";
      hash = "sha256-hFKEMJt8lio/kuuZTDEshZ6NBjpDM65VoS6hl1CTSZ0=";
      wasm = true;
    };
  };

  "elo1lson" = lib.recurseIntoAttrs {
    "90s-anime" = mkLapcePlugin {
      author = "elo1lson";
      name = "90s-anime";
      version = "0.1.0";
      hash = "sha256-XDpidaJY3yAQEJ0IjjW9OZFKLWPt5Hn71A7SX3r+110=";
      wasm = false;
    };
    "lapce-css" = mkLapcePlugin {
      author = "elo1lson";
      name = "lapce-css";
      version = "0.0.2";
      hash = "sha256-zqYxsS4Eyd40sp2jrDfAK2j8tJ0o4YVSjY429UTjbSQ=";
      wasm = true;
    };
  };

  "foxlldev" = lib.recurseIntoAttrs {
    "solarized" = mkLapcePlugin {
      author = "foxlldev";
      name = "solarized";
      version = "0.1.1";
      hash = "sha256-649WE9BcR80HwKnEYEM3O5EgfAiKb/cZFM3bXjjf854=";
      wasm = false;
    };
  };

  "ghishadow" = lib.recurseIntoAttrs {
    "catppuccin" = mkLapcePlugin {
      author = "ghishadow";
      name = "catppuccin";
      version = "0.1.18";
      hash = "sha256-0J/35D2Vf/TAwpl/hEq0TThikzJWF0yYQd/XrIj+xDo=";
      wasm = false;
    };
    "kanagawa" = mkLapcePlugin {
      author = "ghishadow";
      name = "kanagawa";
      version = "0.0.6";
      hash = "sha256-LdNSPVF7tG4EbN50yU4yKENO6wPWkg9Y7qv7pcZoKSQ=";
      wasm = false;
    };
    "lapce-swift" = mkLapcePlugin {
      author = "ghishadow";
      name = "lapce-swift";
      version = "0.1.4";
      hash = "sha256-UjHzSX3dMA13AlA73BKtbGnUKVy3h7zN2Um0cv/3fN0=";
      wasm = true;
    };
    "lapce-zig" = mkLapcePlugin {
      author = "ghishadow";
      name = "lapce-zig";
      version = "0.1.1";
      hash = "sha256-VIqEOoeti283CbdNP+IreRW19lNey5QVWWUWNhclAhU=";
      wasm = true;
    };
    "lightpink" = mkLapcePlugin {
      author = "ghishadow";
      name = "lightpink";
      version = "0.2.8";
      hash = "sha256-oVZ+CRexvBlN1s1sDlAV2qoKFY4ZSmNbPhhqhNWz+M8=";
      wasm = false;
    };
    "rose-pine" = mkLapcePlugin {
      author = "ghishadow";
      name = "rose-pine";
      version = "0.2.6";
      hash = "sha256-V3F+JD5qXA1isT11yHtWZ6vIQx0h7VJaVGrIXL6CGnM=";
      wasm = false;
    };
    "tokyo-night" = mkLapcePlugin {
      author = "ghishadow";
      name = "tokyo-night";
      version = "0.2.0";
      hash = "sha256-JTHsKph1tdHMH0jG9+hzJ+iEtXhQWH42H3CD8ih5e+A=";
      wasm = false;
    };
  };

  "hangj" = lib.recurseIntoAttrs {
    "lapce-plugin-all-in-one" = mkLapcePlugin {
      author = "hangj";
      name = "lapce-plugin-all-in-one";
      version = "0.1.0";
      hash = "sha256-swiW0j4f6hfnC4dHL+dImfmU0AmY1rjxIIbEaanoc40=";
      wasm = true;
    };
  };

  "heartbeast42" = lib.recurseIntoAttrs {
    "neon-night" = mkLapcePlugin {
      author = "heartbeast42";
      name = "neon-night";
      version = "0.1.0";
      hash = "sha256-jTccfuX6uzi/1CI6Ml5Wnp9SY7cJSktTD9nGtirfpaU=";
      wasm = false;
    };
  };

  "instance-id" = lib.recurseIntoAttrs {
    "lapce-powershell" = mkLapcePlugin {
      author = "instance-id";
      name = "lapce-powershell";
      version = "0.0.1";
      hash = "sha256-gQttyneWYYolPnIrBHggbk2XZU9C4+l6SFqfR+rF5L0=";
      wasm = true;
    };
  };

  "jimsynz" = lib.recurseIntoAttrs {
    "lapce-elixir" = mkLapcePlugin {
      author = "jimsynz";
      name = "lapce-elixir";
      version = "0.1.0";
      hash = "sha256-EXVksYNe3F1TpQr7C80F9l1m2Q0Xh4U3soNLjLtvQcY=";
      wasm = true;
    };
  };

  "jm-observer" = lib.recurseIntoAttrs {
    "lldb-win" = mkLapcePlugin {
      author = "jm-observer";
      name = "lldb-win";
      version = "0.0.1";
      hash = "sha256-UVN047LcCuQhltCm/U0DD45znla6qTHrpdvQTkS5ZZU=";
      wasm = true;
    };
  };

  "joyme123" = lib.recurseIntoAttrs {
    "thrift-ls" = mkLapcePlugin {
      author = "joyme123";
      name = "thrift-ls";
      version = "0.0.3";
      hash = "sha256-XEfe7D/sKH5umJcDZ/JtCqniLAaWXNn0Ygbjp1Wmw24=";
      wasm = true;
    };
  };

  "jsanchezba" = lib.recurseIntoAttrs {
    "github-theme" = mkLapcePlugin {
      author = "jsanchezba";
      name = "github-theme";
      version = "0.1.1";
      hash = "sha256-vHJSZ9x/vcIBlEzA/81RtAqdSCN20I/E618RmS476Os=";
      wasm = false;
    };
  };

  "lotosbin" = lib.recurseIntoAttrs {
    "guose" = mkLapcePlugin {
      author = "lotosbin";
      name = "guose";
      version = "0.0.2";
      hash = "sha256-pER+Jk1kc1EFseaHV7umqZFjDZ4A+qXuEXy3opBV558=";
      wasm = false;
    };
  };

  "nekodival" = lib.recurseIntoAttrs {
    "lapce-racket" = mkLapcePlugin {
      author = "nekodival";
      name = "lapce-racket";
      version = "0.0.1";
      hash = "sha256-2CJie32BY6pdbNi1D08u6nBmycOANexMGv4mEHqu9oA=";
      wasm = true;
    };
  };

  "nullndr" = lib.recurseIntoAttrs {
    "lapce-material-icon-theme" = mkLapcePlugin {
      author = "nullndr";
      name = "lapce-material-icon-theme";
      version = "0.0.1";
      hash = "sha256-fq+VjvEjylX1mOwpVL4lyoEoYi1Ddla3ERbeoXwl+eM=";
      wasm = false;
    };
  };

  "nvarner" = lib.recurseIntoAttrs {
    "typst-lsp" = mkLapcePlugin {
      author = "nvarner";
      name = "typst-lsp";
      version = "0.13.0";
      hash = "sha256-ibo6fbq7+WvWVZGp1UB8bf+AeXTn70b5fCIkvTmfivQ=";
      wasm = true;
    };
  };

  "oknozor" = lib.recurseIntoAttrs {
    "lapce-java" = mkLapcePlugin {
      author = "oknozor";
      name = "lapce-java";
      version = "0.3.0";
      hash = "sha256-KbODyIE5QOxCjRBR3c2efuf6QlfxGPLS6zYnMkkUm5s=";
      wasm = true;
    };
  };

  "p-yukusai" = lib.recurseIntoAttrs {
    "black-iris" = mkLapcePlugin {
      author = "p-yukusai";
      name = "black-iris";
      version = "0.1.11";
      hash = "sha256-Olgf3dcDHwdr9HavrxyPAWTf8rRthpYIRCdaVV3lrWM=";
      wasm = false;
    };
  };

  "panekj" = lib.recurseIntoAttrs {
    "lapce-cpp-clangd" = mkLapcePlugin {
      author = "panekj";
      name = "lapce-cpp-clangd";
      version = "2024.2.0";
      hash = "sha256-RHmJdyw7xj0AuDelcbKlmst05IVTMHSadR68porPGQU=";
      wasm = true;
    };
    "lapce-deno" = mkLapcePlugin {
      author = "panekj";
      name = "lapce-deno";
      version = "0.0.1+deno.2.0.2";
      hash = "sha256-iZBRn4X0sq6I+CygrzA0S/ZuWObAfwpTzIiaXPVUlfA=";
      wasm = true;
    };
    "lapce-go" = mkLapcePlugin {
      author = "panekj";
      name = "lapce-go";
      version = "2023.1.0";
      hash = "sha256-HZJW28ve7xLoNOBxKNfFnPWs/Prk+/znvUh8jI6YwMI=";
      wasm = true;
    };
    "lapce-material-icon-theme" = mkLapcePlugin {
      author = "panekj";
      name = "lapce-material-icon-theme";
      version = "0.0.1-beta1";
      hash = "sha256-rdnghlwYJy+oE7Fp76LuO+6bIUcYYJzxiJA8kLFKLbE=";
      wasm = false;
    };
    "lapce-terraform-ls" = mkLapcePlugin {
      author = "panekj";
      name = "lapce-terraform-ls";
      version = "0.0.2+terraform-ls.0.32.7";
      hash = "sha256-hKjT+as+XuXKmSwKsu2p4UdYhc71KojzhZMX/JNoQjw=";
      wasm = true;
    };
    "lapce-toml" = mkLapcePlugin {
      author = "panekj";
      name = "lapce-toml";
      version = "0.0.0";
      hash = "sha256-hSXo5d7DuresKfN8lDlC8SCJ/+NeWZcAH8Xbp3kUwNc=";
      wasm = true;
    };
    "lapce-typescript" = mkLapcePlugin {
      author = "panekj";
      name = "lapce-typescript";
      version = "2022.11.0";
      hash = "sha256-DChRrXfWSL1lynP7yhP4J+OMsr5A/tyWCv9FS/Ks0ew=";
      wasm = true;
    };
    "lapce-yaml" = mkLapcePlugin {
      author = "panekj";
      name = "lapce-yaml";
      version = "0.0.1";
      hash = "sha256-UV21phSBkZMKV4guArxedRgIB5nJlgcukbhmHDc/baU=";
      wasm = true;
    };
    "vscode-themes" = mkLapcePlugin {
      author = "panekj";
      name = "vscode-themes";
      version = "2022.11.0";
      hash = "sha256-ZwCc8KtdgSiovy92c3yr1/tWGitiq9PJblT89TBz+ek=";
      wasm = false;
    };
  };

  "robinv8" = lib.recurseIntoAttrs {
    "lapce-astro" = mkLapcePlugin {
      author = "robinv8";
      name = "lapce-astro";
      version = "0.0.1";
      hash = "sha256-as92p0ZnBfdNPjKrzknaQx7Mj0W5IU2EZgER7rL+EiI=";
      wasm = true;
    };
  };

  "sharpSteff" = lib.recurseIntoAttrs {
    "csharp" = mkLapcePlugin {
      author = "sharpSteff";
      name = "csharp";
      version = "2.0.0";
      hash = "sha256-2wa11YRRSQVEXHkVQch1lsIVmoiHh1KMFTi2HeQAv2g=";
      wasm = true;
    };
  };

  "sleepy-kitten" = lib.recurseIntoAttrs {
    "discord" = mkLapcePlugin {
      author = "sleepy-kitten";
      name = "discord";
      version = "0.2.1";
      hash = "sha256-FepeooMjFgKonCcYtF5cPazWP4lEo4gEnIqUzU5tSxU=";
      wasm = false;
    };
  };

  "sschober" = lib.recurseIntoAttrs {
    "lapce-plugin-rewrap" = mkLapcePlugin {
      author = "sschober";
      name = "lapce-plugin-rewrap";
      version = "0.0.1";
      hash = "sha256-GgQ0479WQeMgcSYP7Os/JqMiX1AvHwNIfjEsxSfZHEc=";
      wasm = true;
    };
  };

  "superlou" = lib.recurseIntoAttrs {
    "lapce-python" = mkLapcePlugin {
      author = "superlou";
      name = "lapce-python";
      version = "0.3.4";
      hash = "sha256-YJyuSr2csIOVqW7pEbp2tmnSFioi+fXA4U/8JZPqWf0=";
      wasm = true;
    };
  };

  "timon-schelling" = lib.recurseIntoAttrs {
    "nushell-lsp" = mkLapcePlugin {
      author = "timon-schelling";
      name = "nushell-lsp";
      version = "0.1.0-rc2";
      hash = "sha256-/s982zGl85kxRoibwSpRiXxXD1Dgq6OUVvMXIUPP//4=";
      wasm = true;
    };
  };

  "tingfeng-key" = lib.recurseIntoAttrs {
    "lapce-prisma" = mkLapcePlugin {
      author = "tingfeng-key";
      name = "lapce-prisma";
      version = "0.1.0";
      hash = "sha256-akbIqaKu9qA/+oPyBwLKY/gpEfG5IXNxr2W0bm2URdU=";
      wasm = true;
    };
  };

  "vikaskaliramna" = lib.recurseIntoAttrs {
    "lapce-deno" = mkLapcePlugin {
      author = "vikaskaliramna";
      name = "lapce-deno";
      version = "0.0.0";
      hash = "sha256-+hu/qxytlyhAbSqGuDC/Qz53bqHSXhN0OAse+zGErAE=";
      wasm = true;
    };
  };

  "willjsaint" = lib.recurseIntoAttrs {
    "cascade-dark" = mkLapcePlugin {
      author = "willjsaint";
      name = "cascade dark";
      version = "0.0.1";
      hash = "sha256-B5QlZ51C3KT016YxtsrvYQkTrJHCzkTy6RBf2NxY0vc=";
      wasm = false;
    };
  };

  "wpkelso" = lib.recurseIntoAttrs {
    "milk-tea" = mkLapcePlugin {
      author = "wpkelso";
      name = "milk-tea";
      version = "0.0.2";
      hash = "sha256-PERWKCqyUOLAMKJI3fESCY/1gQ/hbsBoySMOQPX088M=";
      wasm = false;
    };
  };

  "xiaoxin-sky" = lib.recurseIntoAttrs {
    "lapce-rome" = mkLapcePlugin {
      author = "xiaoxin-sky";
      name = "lapce-rome";
      version = "0.0.1";
      hash = "sha256-fChbExavT24DVvtqQMmXdrlvqTUoaUb5WtQly82PSiY=";
      wasm = true;
    };
    "lapce-vue" = mkLapcePlugin {
      author = "xiaoxin-sky";
      name = "lapce-vue";
      version = "0.0.2";
      hash = "sha256-vE+jAYMO2+F/XLJQBfFmlelLHS1VJsfFs1YBvbrHsxw=";
      wasm = true;
    };
  };

  "zarathir" = lib.recurseIntoAttrs {
    "lapce-dart" = mkLapcePlugin {
      author = "zarathir";
      name = "lapce-dart";
      version = "0.3.0";
      hash = "sha256-XFWBOURWxso4d8sq9Bruh7i5bT5qrSJXr9Qz9AX8GOs=";
      wasm = true;
    };
    "lapce-markdown" = mkLapcePlugin {
      author = "zarathir";
      name = "lapce-markdown";
      version = "0.3.2";
      hash = "sha256-+fn9enUr9y663m/3xloFau1yuJ34GDHDVWmOwYrSAbY=";
      wasm = true;
    };
  };

}
