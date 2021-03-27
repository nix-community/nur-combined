{pkgs, config, ...}:
let
  mkNativefier = pkgs.webapp.wrap;
in {
  whatsapp = mkNativefier {
    name = "WhatsApp";
    url = "web.whatsapp.com";
    icon = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/whatsapp.png";
      sha256 = "1f5bwficjkqxjzanw89yj0rz66zz10k7zhrirq349x9qy9yp3bmc";
    };
  };
  todoist = mkNativefier {
    name = "Todoist";
    url = "todoist.com";
    icon = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/todoist.png";
      sha256 = "05k447nszwygbmly23zrwhq72mql5ix1935p2id1bl19r7yzfmd3";
    };
  };
  remnote = mkNativefier {
    name = "RemNote";
    url = "www.remnote.io/";
    icon = builtins.fetchurl {
      url = "https://www.remnote.io/favicon.ico";
      sha256 = "1iwy8ggwyjjvsd8fpqjji7d10fnvb5w742ccv5q7h5nly0npspmn";
    };
  };
  notion = mkNativefier {
    name = "NotionSo";
    desktopName = "Notion";
    url = "notion.so";
    icon = builtins.fetchurl {
      url = "https://logos-download.com/wp-content/uploads/2019/06/Notion_App_Logo.png";
      sha256 = "16vw52kca3pglykn9q184qgzshys3d2knzy631rp2slkbr301zxf";
    };
  };
  duolingo = mkNativefier {
    name = "Duolingo";
    url = "duolingo.com";
    icon = builtins.fetchurl {
      url = "https://logos-download.com/wp-content/uploads/2016/10/Duolingo_logo_owl.png";
      sha256 = "1059lfaij0lmm1jsywfmnin9z8jalqh8yar9r8sj0qzk4nmjniss";
    };
  };
  youtube-music = mkNativefier {
    name = "YoutubeMusic";
    desktopName = "Youtube Music";
    url = "music.youtube.com";
    icon = builtins.fetchurl {
      url = "https://vancedapp.com/static/media/logo.40712559.svg";
      sha256 = "1xd28aikklqdi11wam97wcp276f8gx9d7f235h8wsqcixndbrm0y";
    };
  };
  planttext = mkNativefier {
    name = "PlantText";
    url = "https://www.planttext.com/";
    icon = builtins.fetchurl {
      url = "https://www.planttext.com/images/blue_gray.png";
      sha256 = "0n1p8g7gjxdp06fh36yqb10jvcbhxfc129xpvi1b10k1qb1vlj1h";
    };
  };
  rainmode = mkNativefier {
    name = "rainvideo";
    desktopName = "Tocar som de chuva";
    url = "https://youtu.be/mPZkdNFkNps";
    icon = "weather-showers";
  };
  gmail = mkNativefier {
    name = "gmail";
    desktopName = "GMail";
    url = "gmail.com";
    icon = builtins.fetchurl {
      url = "https://icons.iconarchive.com/icons/dtafalonso/android-lollipop/256/Gmail-icon.png";
      sha256 = "1cldc9k30rlvchh7ng00hmn0prbh632z8h9fqclj466y8bgdp15j";
    };
  };
}
