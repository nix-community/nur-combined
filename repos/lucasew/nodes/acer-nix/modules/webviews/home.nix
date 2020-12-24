{pkgs, config, ...}:
let
  globalConfig = import ../../../../globalConfig.nix;
  mkNativefier = import ../../../../lib/mkNativefier pkgs;
in
let
  whatsapp = mkNativefier {
    name = "WhatsApp";
    url = "https://web.whatsapp.com";
    electron = pkgs.electron_9;
    icon = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/whatsapp.png";
      sha256 = "1f5bwficjkqxjzanw89yj0rz66zz10k7zhrirq349x9qy9yp3bmc";
    };
    props = {
      userAgent = "Mozilla/5.0 (X11; Datanyze; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36";
      singleInstance = true;
      # tray = true;
    };
  };
  todoist = mkNativefier {
    name = "Todoist";
    url = "https://todoist.com";
    electron = pkgs.electron_9;
    icon = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/todoist.png";
      sha256 = "05k447nszwygbmly23zrwhq72mql5ix1935p2id1bl19r7yzfmd3";
    };
    props = {
      singleInstance = true;
    };
  };
  remnote = mkNativefier {
    name = "RemNote";
    electron = pkgs.electron_9;
    url = "https://www.remnote.io/";
    icon = builtins.fetchurl {
      url = "https://www.remnote.io/favicon.ico";
      sha256 = "1iwy8ggwyjjvsd8fpqjji7d10fnvb5w742ccv5q7h5nly0npspmn";
    };
  };
  notion = mkNativefier {
    name = "NotionSo";
    url = "https://notion.so";
    icon = builtins.fetchurl {
      url = "https://logos-download.com/wp-content/uploads/2019/06/Notion_App_Logo.png";
      sha256 = "16vw52kca3pglykn9q184qgzshys3d2knzy631rp2slkbr301zxf";
    };
  };
  duolingo = mkNativefier {
    name = "Duolingo";
    url = "https://duolingo.com";
    icon = builtins.fetchurl {
      url = "https://logos-download.com/wp-content/uploads/2016/10/Duolingo_logo_owl.png";
      sha256 = "1059lfaij0lmm1jsywfmnin9z8jalqh8yar9r8sj0qzk4nmjniss";
    };
  };
  geforcenow = mkNativefier {
    name = "GeforceNow";
    url = "https://play.geforcenow.com/";
    electron = pkgs.electron_9;
    # icon = fetch "https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/whatsapp.png";
    props = {
      userAgent = "Mozilla/5.0 (X11; CrOS x86_64 13099.85.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.110 Safari/537.36";
      singleInstance = true;
      # tray = true;
    };
  };

in
{
    home.packages = with pkgs; [
      whatsapp
      remnote
      notion
      duolingo
      todoist
      geforcenow
    ];
}
