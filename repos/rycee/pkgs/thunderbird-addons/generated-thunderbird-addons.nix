{ buildMozillaXpiAddon, fetchurl, lib, stdenv }:
  {
    "dictionnaire-français1" = buildMozillaXpiAddon {
      pname = "dictionnaire-français1";
      version = "6.3.1webext";
      addonId = "fr-dicollecte@dictionaries.addons.mozilla.org";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1012573/french_spelling_dictionary-6.3.1webext.xpi?src=";
      sha256 = "e53cbe960ae00742e16afab0aee1990b94ac44505fea5caeef4b3265cbf7036e";
      meta = with lib;
      {
        homepage = "http://www.dicollecte.org/";
        description = "Spelling dictionary for the French language.";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "eas-4-tbsync" = buildMozillaXpiAddon {
      pname = "eas-4-tbsync";
      version = "4.17";
      addonId = "eas4tbsync@jobisoft.de";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1040394/provider_fur_exchange_activesync-4.17-tb.xpi?src=";
      sha256 = "f564c4063e4bf603c81ca0ff5dfa3432fb946179a15208cc73022fd747a70466";
      meta = with lib;
      {
        homepage = "https://github.com/jobisoft/EAS-4-TbSync";
        description = "Add sync support for Exchange ActiveSync (EAS v2.5 &amp; v14.0) accounts to TbSync";
        license = licenses.mpl20;
        mozPermissions = [ "notifications" ];
        platforms = platforms.all;
      };
    };
    "provider-for-google-calendar" = buildMozillaXpiAddon {
      pname = "provider-for-google-calendar";
      version = "128.5.11";
      addonId = "{a62ef8ec-5fdc-40c2-873c-223b8a6925cc}";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1045009/provider_for_google_calendar-128.5.11-tb.xpi?src=";
      sha256 = "519cac1cf0ad2fcdecb301ad47ad50ecad635742feb8a01f746c2de951a12455";
      meta = with lib;
      {
        homepage = "https://github.com/kewisch/gdata-provider/wiki/FAQ";
        description = "Provider for Google Calendar connects Thunderbird with Google Calendar for full task sync, conference details, and scheduling support. It offers deeper integration than Thunderbird’s native support using Google’s official API.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "send-later" = buildMozillaXpiAddon {
      pname = "send-later";
      version = "10.7.8";
      addonId = "sendlater3@kamens.us";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1042516/send_later-10.7.8-tb.xpi?src=";
      sha256 = "c6290ebbc8a22431d9cd59d12a62835dbd0df749bba6ff162c07b4e84fc503f0";
      meta = with lib;
      {
        homepage = "https://extended-thunder.github.io/send-later/";
        description = "True \"Send Later\" functionality to schedule the time for sending an email.";
        license = licenses.mpl20;
        mozPermissions = [
          "accountsFolders"
          "accountsRead"
          "activeTab"
          "addressBooks"
          "alarms"
          "compose"
          "compose.save"
          "compose.send"
          "menus"
          "messagesDelete"
          "messagesImport"
          "messagesMove"
          "messagesRead"
          "messagesUpdate"
          "notifications"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "tbkeys-lite" = buildMozillaXpiAddon {
      pname = "tbkeys-lite";
      version = "2.4.3";
      addonId = "tbkeys-lite@addons.thunderbird.net";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1044591/tbkeys_lite-2.4.3-tb.xpi?src=";
      sha256 = "42cdfeae8e4e83725a4442881c0f00ff4759aa03dcd7d71d55a200058e2a1650";
      meta = with lib;
      {
        description = "Custom Thunderbird keybindings\n\nThis add-on is a follow on to Keyconfig which is no longer supported.\n\nIt is aimed at power users. Please look at the GitHub site before leaving a one star review about documentation or usability.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "tbsync" = buildMozillaXpiAddon {
      pname = "tbsync";
      version = "4.16";
      addonId = "tbsync@jobisoft.de";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1040395/tbsync-4.16-tb.xpi?src=";
      sha256 = "60aba312770e5a49dcedfb8db67cb57a9f8daf12ffd49dca2d7ed1af825bbcbb";
      meta = with lib;
      {
        homepage = "https://github.com/jobisoft/TbSync";
        description = "TbSync is a central user interface to manage cloud accounts and synchronize their contact, task and calendar information with Thunderbird.";
        license = licenses.mpl20;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "urgentmail" = buildMozillaXpiAddon {
      pname = "urgentmail";
      version = "1.5";
      addonId = "mailAlert@einKnie";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1019990/urgentmail-1.5-tb.xpi?src=";
      sha256 = "350c1b9e94152d331188f98454c4a9edbbb0b4b2c2ba0ff32504df5e693db048";
      meta = with lib;
      {
        homepage = "https://github.com/einKnie/urgentMail";
        description = "Raise X11 urgent flag if new mail is received.\n\nThis addon listens for incoming mails and causes the Thunderbird window to draw attention.";
        license = licenses.gpl3;
        mozPermissions = [ "messagesRead" "accountsRead" "storage" ];
        platforms = platforms.all;
      };
    };
  }