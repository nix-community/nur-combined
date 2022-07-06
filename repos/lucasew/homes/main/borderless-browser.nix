{ pkgs, ... }:
let
  inherit (pkgs) fetchurl;
in {
  borderless-browser.apps = {
    teste = {
      desktopName = "Teste";
      url = "https://google.com";
    };
    whatsapp = {
      desktopName = "WhatsApp";
      url = "web.whatsapp.com";
      icon = (fetchurl {
        url = "https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/whatsapp.png";
        sha256 = "1f5bwficjkqxjzanw89yj0rz66zz10k7zhrirq349x9qy9yp3bmc";
      }).outPath;
    };
    notion = {
      desktopName = "Notion";
      url = "notion.so";
      icon = (fetchurl {
        url = "https://logos-download.com/wp-content/uploads/2019/06/Notion_App_Logo.png";
        sha256 = "16vw52kca3pglykn9q184qgzshys3d2knzy631rp2slkbr301zxf";
      }).outPath;
    };
    duolingo = {
      desktopName = "Duolingo";
      url = "duolingo.com";
      icon = (fetchurl {
        url = "https://logos-download.com/wp-content/uploads/2016/10/Duolingo_logo_owl.png";
        sha256 = "1059lfaij0lmm1jsywfmnin9z8jalqh8yar9r8sj0qzk4nmjniss";
      }).outPath;
    };
    youtube-music =  {
      desktopName = "Youtube Music";
      url = "music.youtube.com";
      icon = (fetchurl {
        url = "https://vancedapp.com/static/media/logo.866a4e0b.svg";
        sha256 = "1axznpmfgmfqjgnq7z7vdjwmdsrk0qpc1rdlv9yyrcxfkyzqmvdv";
      }).outPath;
    };
    planttext =  {
      desktopName = "PlantText";
      url = "https://www.planttext.com/";
      icon = (fetchurl {
        url = "https://www.planttext.com/images/blue_gray.png";
        sha256 = "0n1p8g7gjxdp06fh36yqb10jvcbhxfc129xpvi1b10k1qb1vlj1h";
      }).outPath;
    };
    rainmode =  {
      desktopName = "Tocar som de chuva";
      url = "https://youtu.be/mPZkdNFkNps";
      icon = "weather-showers";
    };
    gmail =  {
      desktopName = "GMail";
      url = "gmail.com";
      icon = (fetchurl {
        url = "https://icons.iconarchive.com/icons/dtafalonso/android-lollipop/256/Gmail-icon.png";
        sha256 = "1cldc9k30rlvchh7ng00hmn0prbh632z8h9fqclj466y8bgdp15j";
      }).outPath;
    };
    keymash =  {
      desktopName = "keyma.sh: Keyboard typing train";
      url = "https://keyma.sh/learn";
      icon = (fetchurl {
        url = "https://keyma.sh/static/media/logo_svg.ead5cacb.svg";
        sha256 = "1i6py2gnpmf548zwakh9gscnk5ggsd1j98z80yb6mr0fm84bgizy";
      }).outPath;
    };
    calendar =  {
      desktopName = "Calendário";
      url = "https://calendar.google.com/calendar/u/0/r/customday";
      icon = "x-office-calendar";
    };
    twitchLive =  {
      desktopName = "Dashboard de Live";
      url = "https://dashboard.twitch.tv/stream-manager";
    };
    trello-facul = {
      desktopName = "Trello Faculdade";
      url = "https://trello.com/b/ov0pbUtC/facul";
    };
    trello-pessoal = {
      desktopName = "Trello Pessoal";
      url = "https://trello.com/b/bjoRKSM2/pessoal";
    };
    trello-sides = {
      desktopName = "Trello Side Projects";
      url = "https://trello.com/b/36ncJYYV/side-projects";
    };
    trello-dashboard = {
      desktopName = "Trello Dashboard";
      url = "trello.com";
    };
    geforce-now = {
      desktopName = "GeForce Now";
      url = "play.geforcenow.com";
      icon = "nvidia";
    };
  };
}
