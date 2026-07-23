{ buildMozillaXpiAddon, fetchurl, lib, stdenv }:
  {
    "cardbook" = buildMozillaXpiAddon {
      pname = "cardbook";
      version = "106.2";
      addonId = "cardbook@vigneau.philippe";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1049108/cardbook-106.2-tb.xpi?src=";
      sha256 = "9027f7d7e211771569c38346640947c68a5ecb28f34180482ba3da5f682e0720";
      meta = with lib;
      {
        homepage = "https://gitlab.com/CardBook/CardBook";
        description = "A new Thunderbird address book based on the CardDAV and vCard standards.\n\nTwitter: <a rel=\"nofollow\" href=\"https://twitter.com/CardBookAddon\">@CardBookAddon</a>";
        license = licenses.mpl20;
        mozPermissions = [
          "compose"
          "accountsRead"
          "messagesRead"
          "addressBooks"
          "clipboardRead"
          "clipboardWrite"
          "storage"
          "unlimitedStorage"
          "tabs"
          "menus"
          "menus.overrideContext"
          "identity"
          "downloads"
          "management"
        ];
        platforms = platforms.all;
      };
    };
    "dictionary-german" = buildMozillaXpiAddon {
      pname = "dictionary-german";
      version = "2.1";
      addonId = "de-DE@dictionaries.addons.mozilla.org";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1021549/german_dictionary-2.1.xpi?src=";
      sha256 = "ceb6e0c7076e36e0f70d1375f9763690079cce55f3feceeaeea9dfdb8b1cb47f";
      meta = with lib;
      {
        description = "German Dictionary (new Orthography) for spellchecking in Mozilla products";
        license = licenses.lgpl21;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
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
      version = "4.18";
      addonId = "eas4tbsync@jobisoft.de";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1046520/provider_fur_exchange_activesync-4.18-tb.xpi?src=";
      sha256 = "2923e13adbcc2fadfe6fe4fa65f01c43b1782765ff2ed3cf125515e2df47584d";
      meta = with lib;
      {
        homepage = "https://github.com/jobisoft/EAS-4-TbSync";
        description = "Add sync support for Exchange ActiveSync (EAS v2.5 &amp; v14.0) accounts to TbSync";
        license = licenses.mpl20;
        mozPermissions = [ "notifications" ];
        platforms = platforms.all;
      };
    };
    "external-editor-revived" = buildMozillaXpiAddon {
      pname = "external-editor-revived";
      version = "1.2.0";
      addonId = "external-editor-revived@tsundere.moe";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1036386/external_editor_revived-1.2.0-tb.xpi?src=";
      sha256 = "415dad41ede63969a10c04e223d80b9e438c58adfb24a5a0c9811778f5be5a76";
      meta = with lib;
      {
        homepage = "https://github.com/Frederick888/external-editor-revived";
        description = "Edit emails in external editors such as Vim, Neovim, Emacs, etc.";
        license = licenses.gpl3;
        mozPermissions = [
          "compose"
          "compose.send"
          "accountsRead"
          "messagesRead"
          "storage"
          "notifications"
          "nativeMessaging"
        ];
        platforms = platforms.all;
      };
    };
    "filtaquilla" = buildMozillaXpiAddon {
      pname = "filtaquilla";
      version = "6.2.2";
      addonId = "filtaquilla@mesquilla.com";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1048356/filtaquilla-6.2.2-tb.xpi?src=";
      sha256 = "3c36a5ca528000f83572214b6720642de8083359e9722dbf4fa438e2f95cd872";
      meta = with lib;
      {
        homepage = "http://quickfilters.mozdev.org/filtaquilla.html";
        description = "Adds many new mail filter actions - launch a file, suppress notification, remove star or tag, mark replied or unread, copy as \"read\", append text to subject.";
        license = licenses.gpl3;
        mozPermissions = [
          "messagesRead"
          "messagesModifyPermanent"
          "menus"
          "notifications"
          "storage"
          "tabs"
        ];
        platforms = platforms.all;
      };
    };
    "filter-manager" = buildMozillaXpiAddon {
      pname = "filter-manager";
      version = "1.3";
      addonId = "filterManager@dillinger";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1036137/filter_manager-1.3-tb.xpi?src=";
      sha256 = "0e386d269c28e79231567fae0256b022ccb28db597081ad5756d1f99309cc4ef";
      meta = with lib;
      {
        homepage = "https://addons.thunderbird.net/en-US/thunderbird/addon/filter-manager/";
        description = "Adds a Filters Button, opens Filter Manager";
        license = licenses.gpl3;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "grammar-and-spell-checker" = buildMozillaXpiAddon {
      pname = "grammar-and-spell-checker";
      version = "8.11.2";
      addonId = "languagetool-mailextension@languagetool.org";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1031394/grammatik_und_rechtschreibprufung_languagetool-8.11.2-tb.xpi?src=";
      sha256 = "80168a2485e33ed7215d33542934630fd899d8e4aa646970ef13238ec68af2bc";
      meta = with lib;
      {
        homepage = "https://languagetool.org/";
        description = "Check your emails for spelling and grammar issues";
        license = {
          shortName = "languagetool";
          fullName = "Custom License for LanguageTool";
          url = "https://languagetool.org/legal/";
          free = false;
        };
        mozPermissions = [
          "activeTab"
          "tabs"
          "storage"
          "compose"
          "menus"
          "browserSettings"
          "alarms"
          "<all_urls>"
          "http://*/*"
          "https://*/*"
          "file:///*"
        ];
        platforms = platforms.all;
      };
    };
    "html-source-editor" = buildMozillaXpiAddon {
      pname = "html-source-editor";
      version = "1.8";
      addonId = "edithtmlsource@jobisoft.de";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1040652/html_source_editor-1.8-tb.xpi?src=";
      sha256 = "c3ad5ab0d40af196c08b8544dd1dae473a8379155c3bfe558d8e413f09062f64";
      meta = with lib;
      {
        homepage = "https://github.com/jobisoft/HtmlSourceEditor";
        description = "Allows to edit the source of the currently composed message. A simple alternative to ThunderHTMLedit.";
        license = licenses.mpl20;
        mozPermissions = [ "compose" "menus" ];
        platforms = platforms.all;
      };
    };
    "manually-sort-folders" = buildMozillaXpiAddon {
      pname = "manually-sort-folders";
      version = "2.3.0";
      addonId = "tbsortfolders@xulforum.org";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1021687/manually_sort_folders-2.3.0-tb.xpi?src=";
      sha256 = "ef750e487ba259142d8281e630440ed5965fa1da3d6c9b0e9ce13ccb2cc0e19d";
      meta = with lib;
      {
        homepage = "https://github.com/protz/Manually-Sort-Folders/";
        description = "This extension allows you to manually sort (order) your folders in the folder pane of Thunderbird or automatically sort them, but in a better way. This extension also allows you to re-order accounts in the folder pane.";
        license = licenses.gpl2;
        mozPermissions = [];
        platforms = platforms.all;
      };
    };
    "owl-for-exchange" = buildMozillaXpiAddon {
      pname = "owl-for-exchange";
      version = "1.5.3";
      addonId = "owl@beonex.com";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1049033/eule_fur_exchange-1.5.3-tb.xpi?src=";
      sha256 = "b540ccd87c73e1ba1edf1109ceaf59e891317f6b6af7eae2a31f5d2075da3186";
      meta = with lib;
      {
        homepage = "https://www.beonex.com/owl/";
        description = "Allows you to use your Exchange and Office365 email account with Thunderbird using Outlook Web Access (OWA).";
        license = {
          shortName = "owl-for-exchange";
          fullName = "End-User License Agreement (EULA) for Owl";
          url = "https://addons.thunderbird.net/en-US/thunderbird/addon/owl-for-exchange/eula/";
          free = false;
        };
        mozPermissions = [
          "accountsRead"
          "addressBooks"
          "contextualIdentities"
          "cookies"
          "menus"
          "storage"
          "tabs"
          "webNavigation"
          "webRequest"
          "webRequestBlocking"
          "https://*/*"
          "https://teams.microsoft.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "provider-for-google-calendar" = buildMozillaXpiAddon {
      pname = "provider-for-google-calendar";
      version = "128.5.12";
      addonId = "{a62ef8ec-5fdc-40c2-873c-223b8a6925cc}";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1048156/provider_for_google_calendar-128.5.12-tb.xpi?src=";
      sha256 = "81c3c2531d82033518c9f68f747adf99ef259e6ff0de9426751eae87d6023372";
      meta = with lib;
      {
        homepage = "https://github.com/kewisch/gdata-provider/wiki/FAQ";
        description = "Provider for Google Calendar connects Thunderbird with Google Calendar for full task sync, conference details, and scheduling support. It offers deeper integration than Thunderbird’s native support using Google’s official API.";
        license = licenses.mpl20;
        mozPermissions = [ "storage" ];
        platforms = platforms.all;
      };
    };
    "quickfilters" = buildMozillaXpiAddon {
      pname = "quickfilters";
      version = "6.13.1";
      addonId = "quickFilters@axelg.com";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1048778/quickfilters-6.13.1-tb.xpi?src=";
      sha256 = "afd6efa30bd62e6184acf30d2a15bfbd69b5dcf846932635870f4838fd6c73de";
      meta = with lib;
      {
        homepage = "https://quickfilters.quickfolders.org/";
        description = "Quickly generate mail filters on the fly, by dragging and dropping mails and analyzing their attributes. Create a filter in less than 10 seconds, it's as easy as: drag, click, click.\n\nBy popular demand, supports SORTING filters alphabetically.";
        license = {
          shortName = "quickfilters";
          fullName = "quickFilters license (CC BY-ND 4.0)";
          url = "https://addons.thunderbird.net/en-US/thunderbird/addon/quickfilters/license/";
          free = false;
        };
        mozPermissions = [
          "accountsRead"
          "clipboardRead"
          "notifications"
          "menus"
          "messagesRead"
          "storage"
          "tabs"
        ];
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
    "tb-langpack-de" = buildMozillaXpiAddon {
      pname = "tb-langpack-de";
      version = "153.0.20260722.155700";
      addonId = "langpack-de@thunderbird.mozilla.org";
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1049471/deutsch_de_language_pack-153.0.20260722.155700-tb.xpi?src=";
      sha256 = "c536023f0e76a74c95df4554372d93f8673a063e83c4b7a6316072c622be4d53";
      meta = with lib;
      {
        description = "Deutsch (de) Language Pack";
        license = licenses.mpl20;
        mozPermissions = [];
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