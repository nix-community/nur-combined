{ ... }: {

  # added over time
  "browser.tabs.insertAfterCurrent" = true;
  "browser.tabs.unloadOnLowMemory" = true;
  "browser.low_commit_space_threshold_mb" = 1500;

  # general
  "extensions.autoDisableScopes" = 0;
  "extensions.enabledScopes" = 15;
  "browser.search.region" = "AT";
  "browser.aboutConfig.showWarning" = false;
  "javascript.options.mem.gc_parallel_marking" = true;
  "browser.download.dir" = "/home/me/work/downloads";
  "browser.startup.couldRestoreSession.count" = 5;
  "browser.toolbars.bookmarks.visibility" = "never";
  "devtools.everOpened" = true;
  "middlemouse.paste" = false;
  "browser.download.folderList" = 1;
  "extensions.langpacks.signatures.required" = false;
  "browser.shell.checkDefaultBrowser" = false;

  # better widnow settings for tiling vm
  "browser.tabs.inTitlebar" = 0;

  # so that firefox reacts fast to changes in /etc/hosts
  "network.dnsCacheExpiration" = 0;

  # dont sync theme
  # so that "browser.theme.content-theme" is not always set to 2
  "services.sync.prefs.sync.extensions.activeThemeID" = false;

  # allow to install my own addons
  "xpinstall.signatures.required" = false;
  "xpinstall.whitelist.required" = true;

  # set theme
  #"extensions.activeThemeID" = "visionary-bold-colorway@mozilla.org";
    # - this one does not work
  "extensions.activeThemeID" = "{8d38d24a-dd1b-4142-8873-bbaa32e4e44f}";
  "browser.theme.content-theme" = 0; # content dark theme
  "browser.theme.toolbar-theme" = 0; # toolbar dark theme


  # have acces to browser console
  "devtools.chrome.enabled" = true;

  #always show downloads button
  "browser.download.autohideButton" = false;

  # better cache
  "browser.cache.disk.capacity" = 4560000;
  "browser.cache.disk.smart_size.enabled" = false;
  "browser.cache.check_doc_frequency" = 2;
    # http://kb.mozillazine.org/Browser.cache.check_doc_frequency


  # the header customisation
  "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":["sync-button"],"unified-extensions-area":["jid1-93cwpmrbvpjrqa_jetpack-browser-action","_react-devtools-browser-action","grepper_codegrepper_com-browser-action","simple-translate_sienori-browser-action","_d04b0b40-3dab-4f0b-97a6-04ec3eddbfb0_-browser-action","_b0721213-dc0b-4ae0-8436-8c14f0022a37_-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","customizableui-special-spring1","urlbar-container","zoom-controls","customizableui-special-spring7","screenshot-button","fullscreen-button","developer-button","bookmarks-menu-button","downloads-button","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","adguardadblocker_adguard_com-browser-action","extension_one-tab_com-browser-action","side-view_mozilla_org-browser-action","unified-extensions-button","reset-pbm-toolbar-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["preferences-button","personal-bookmarks"]},"seen":["developer-button","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","extension_one-tab_com-browser-action","_d04b0b40-3dab-4f0b-97a6-04ec3eddbfb0_-browser-action","grepper_codegrepper_com-browser-action","save-to-pocket-button","_react-devtools-browser-action","jid1-93cwpmrbvpjrqa_jetpack-browser-action","adguardadblocker_adguard_com-browser-action","side-view_mozilla_org-browser-action","simple-translate_sienori-browser-action","profiler-button","reset-pbm-toolbar-button","_b0721213-dc0b-4ae0-8436-8c14f0022a37_-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list","unified-extensions-area"],"currentVersion":20,"newElementCount":26}'';


  # keep extension uuids the same ... so that the bitwaredne pass-store and onetab stores stay the same

  "extensions.webextensions.uuids" = builtins.toJSON {
    "extension@one-tab.com" = "e2297551-90b4-4da0-92c8-1d00cda2d080";
    "adguardadblocker@adguard.com" = "b73239bf-cb93-4985-8f3b-71b32a3b3527";
    "grepper@codegrepper.com" = "7cfa9e68-fba7-4eb9-8f3b-d4562a31b476";

    # bitwarden 
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "e563a533-4e66-4b75-bbec-176bb803d96c";
  };

  "extensions.webextensions.ExtensionStorageIDB.migrated.adguardadblocker@adguard.com" = true;
  "extensions.webextensions.ExtensionStorageIDB.migrated.extension@one-tab.com" = true;
  "extensions.webextensions.ExtensionStorageIDB.migrated.grepper@codegrepper.com" = true;
  "extensions.webextensions.ExtensionStorageIDB.migrated.screenshots@mozilla.org" = true;
  "extensions.webextensions.ExtensionStorageIDB.migrated.{446900e4-71c2-419f-a6a7-df9c091e268b}" = true;


  # to not show startup dialogs
  "browser.eme.ui.firstContentShown" = true;
  "browser.engagement.ctrlTab.has-used" = true;
  "browser.engagement.downloads-button.has-used" = true;
  "browser.engagement.fxa-toolbar-menu-button.has-used" = true;
  "browser.engagement.home-button.has-used" = true;
  "browser.engagement.library-button.has-used" = true;
  "browser.engagement.sidebar-button.has-used" = true;
  "distribution.archlinux.bookmarksProcessed" = true;
  "distribution.canonical.bookmarksProcessed" = true;
  "distribution.iniFile.exists.appversion" = "122.0a1";
  "distribution.iniFile.exists.value" = false;
  "distribution.nixos.bookmarksProcessed" = true;
  "browser.firefox-view.feature-tour" = ''{"message":"FIREFOX_VIEW_FEATURE_TOUR","screen":"","complete":true}'';
  "trailhead.firstrun.didSeeAboutWelcome" = true;


  # disable autofill
  "signon.autofillForms" = false;
  "signon.firefoxRelay.feature" = "offered";
  "signon.generation.enabled" = false;
  "signon.management.page.breach-alerts.enabled" = false;
  "signon.rememberSignons" = false;


  # interesting
  # browser.bookmarks.defaultLocation	toolbar_____	
  # browser.migration.version	142	
  # browser.fixup.dns_first_for_single_words	true	
  # browser.fixup.domainwhitelist.router	true	
  # browser.startup.homepage	about:blank	
  # extensions.activeThemeID	visionary-bold-colorway@mozilla.org	
  # network.dns.offline-localhost	false	
  # network.dnsCacheExpiration	0	
  # pref.privacy.disable_button.cookie_exceptions	false	
  # pref.privacy.disable_button.tracking_protection_exceptions	false	
  # pref.privacy.disable_button.view_passwords	false	


  ################### devtools not used ##########################
  #devtools.aboutdebugging.collapsibilities.processes	false	

  #devtools.debugger.end-panel-size	57	
  #devtools.debugger.event-listeners-visible	true	
  #devtools.debugger.pause-on-caught-exceptions	false	

  #devtools.debugger.prefs-schema-version	11	
  #devtools.debugger.remote-enabled	true	
  #devtools.debugger.start-panel-size	155	


  #devtools.netmonitor.msg.visibleColumns	["data","time"]	
  #devtools.netmonitor.panes-network-details-height	403	
  #devtools.netmonitor.panes-network-details-width	549	
  #devtools.netmonitor.panes-search-height	237	
  #devtools.netmonitor.panes-search-width	250	
  #devtools.performance.new-panel-onboarding	false	
  #devtools.performance.recording.entries	134217728	
  #devtools.performance.recording.features	["screenshots","js","stackwalk","cpu","processcpu"]	
  #devtools.performance.recording.threads	["GeckoMain","Compositor","Renderer","SwComposite","DOM Worker"]	
  #devtools.responsive.reloadNotification.enabled	false	
  #devtools.responsive.viewport.height	732	
  #devtools.responsive.viewport.width	680	
  #devtools.theme	auto	
  #devtools.theme.show-auto-theme-info	false	
  #devtools.toolbox.footer.height	633	
  #devtools.toolbox.host	right	
  #devtools.toolbox.previousHost	bottom	
  #devtools.toolbox.sidebar.width	431	
  #devtools.toolbox.splitconsoleHeight	98	
  #devtools.toolbox.tabsOrder	inspector,webconsole,netmonitor,jsdebugger,styleeditor,performance,memory,storage,accessibility,application	
  #devtools.toolbox.zoomValue	1.2	
  #devtools.toolsidebar-height.inspector	345	
  #devtools.toolsidebar-width.inspector	383	
  #devtools.toolsidebar-width.inspector.splitsidebar	225	
  #devtools.webconsole.filter.debug	false	
  #devtools.webconsole.filter.info	false	
  #devtools.webconsole.input.editorOnboarding	false	
  #devtools.webconsole.input.editorWidth	393	
  #devtools.webextensions.@react-devtools.enabled	true	

}
