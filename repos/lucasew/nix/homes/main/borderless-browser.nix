{ pkgs, ... }:
let
  inherit (pkgs) fetchurl;
in
{
  # TODO: automate installation of extensions
  # CHROME_DONT_BORDERLESS=1 runs them borderfull
  borderless-browser.apps = {
    teste = {
      desktopName = "Teste";
      url = "https://google.com";
    };
    reemo = {
      desktopName = "Remote control";
      url = "https://reemo.io";
    };
    clickup = {
      desktopName = "ClickUp";
      url = "https://clickup.com";
    };
    facebook = {
      desktopName = "Facebook"; # no need for web containers lol
      url = "https://facebook.com";
      profile = "facebook";
    };
    twitter = {
      # https://chrome.google.com/webstore/detail/control-panel-for-twitter/kpmjjdhbcfebfjgdnpjagcndoelnidfj
      desktopName = "Twitter"; # no need for web containers lol
      url = "https://twitter.com";
      profile = "twitter";
    };
    discord-pessoal = {
      desktopName = "Discord (pessoal)";
      url = "https://discord.com/channels/me";
      profile = "discord-pessoal";
      icon = "discord";
    };
    discord-profissional = {
      desktopName = "Discord (profissional)";
      url = "https://discord.com/channels/me";
      profile = "discord-profissional";
      icon = "discord";
    };
    youtube-tv = {
      # https://chrome.google.com/webstore/detail/youtube-for-tv/gmmbpchnelmlmndfnckechknbohhjpge/related
      desktopName = "YouTube (UI para TV)";
      url = "https://youtube.com/tv";
      profile = "youtube-tv";
    };
    whatsapp = {
      desktopName = "WhatsApp";
      url = "web.whatsapp.com";
      profile = "zap";
      icon =
        (fetchurl {
          url = "https://raw.githubusercontent.com/jiahaog/nativefier-icons/gh-pages/files/whatsapp.png";
          sha256 = "1f5bwficjkqxjzanw89yj0rz66zz10k7zhrirq349x9qy9yp3bmc";
        }).outPath;
    };
    notion = {
      desktopName = "Notion";
      url = "notion.so";
      profile = "notion";
      icon =
        (fetchurl {
          url = "https://logos-download.com/wp-content/uploads/2019/06/Notion_App_Logo.png";
          sha256 = "16vw52kca3pglykn9q184qgzshys3d2knzy631rp2slkbr301zxf";
        }).outPath;
    };
    duolingo = {
      desktopName = "Duolingo";
      url = "duolingo.com";
      icon =
        (fetchurl {
          url = "https://logos-download.com/wp-content/uploads/2016/10/Duolingo_logo_owl.png";
          sha256 = "1059lfaij0lmm1jsywfmnin9z8jalqh8yar9r8sj0qzk4nmjniss";
        }).outPath;
    };
    youtube-music = {
      desktopName = "Youtube Music";
      url = "music.youtube.com";
      profile = "youtubemusic";
      # icon = (fetchurl {
      #  url = "https://vancedapp.com/static/media/logo.866a4e0b.svg";
      #  sha256 = "sha256-ctMsRKAITCRWDewvv4biPWNyJFyPKIrpOaHYaNTd3d8=";
      # }).outPath;
    };
    planttext = {
      desktopName = "PlantText";
      url = "https://www.planttext.com/";
      icon =
        (fetchurl {
          url = "https://www.planttext.com/images/blue_gray.png";
          sha256 = "0n1p8g7gjxdp06fh36yqb10jvcbhxfc129xpvi1b10k1qb1vlj1h";
        }).outPath;
    };
    rainmode = {
      desktopName = "Tocar som de chuva";
      url = "https://youtu.be/mPZkdNFkNps";
      icon = "weather-showers";
    };
    gmail = {
      desktopName = "GMail";
      url = "gmail.com";
      icon =
        (fetchurl {
          url = "https://icons.iconarchive.com/icons/dtafalonso/android-lollipop/256/Gmail-icon.png";
          sha256 = "sha256-zNXr51wUMBnWtIHCoW9kv7ON/6HHB2p3c/e0UmyXUuc=";
        }).outPath;
    };
    keymash = {
      desktopName = "keyma.sh: Keyboard typing train";
      url = "https://keyma.sh/learn";
      #icon = (fetchurl {
      #  url = "https://keyma.sh/static/media/logo_svg.ead5cacb.svg";
      #  sha256 = "1i6py2gnpmf548zwakh9gscnk5ggsd1j98z80yb6mr0fm84bgizy";
      #}).outPath;
    };
    calendar = {
      desktopName = "Calendário";
      url = "https://calendar.google.com/calendar/u/0/r/customday";
      icon = "x-office-calendar";
    };
    twitchLive = {
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
