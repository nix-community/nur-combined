{ callPackage, mylibs, composerEnv, lib }:
rec {
  adminer = callPackage ./adminer {};
  apache-theme = callPackage ./apache-theme {};
  awl = callPackage ./awl {};
  davical = callPackage ./davical {};
  diaspora = callPackage ./diaspora { inherit mylibs; };

  dokuwiki = callPackage ./dokuwiki { inherit mylibs; };
  dokuwiki-with-plugins = dokuwiki.withPlugins (builtins.attrValues dokuwiki-plugins);
  dokuwiki-plugins = let
    names = [ "farmer" "todo" ];
  in
    lib.attrsets.genAttrs names
      (name: callPackage (./dokuwiki/plugins + "/${name}.nix") {});

  etherpad-lite = callPackage ./etherpad-lite {};
  etherpad-lite-with-modules = etherpad-lite.withModules (builtins.attrValues etherpad-lite-modules);
  etherpad-lite-modules = let
    nodeEnv = callPackage mylibs.nodeEnv {};
    names = [
      "ep_aa_file_menu_toolbar" "ep_adminpads" "ep_align" "ep_bookmark"
      "ep_clear_formatting" "ep_colors" "ep_copy_paste_select_all"
      "ep_cursortrace" "ep_embedmedia" "ep_font_family" "ep_font_size"
      "ep_headings2" "ep_ldapauth" "ep_line_height" "ep_markdown"
      "ep_previewimages" "ep_ruler" "ep_scrollto" "ep_set_title_on_pad"
      "ep_subscript_and_superscript" "ep_timesliderdiff"
    ];
  in
    # nix files are built using node2nix -i node-packages.json
    lib.attrsets.genAttrs names
    (name: (callPackage (./etherpad-lite/modules + "/${name}/node-packages.nix") { inherit nodeEnv; })
      .${name}.overrideAttrs(old: { passthru = (old.passthru or {}) // { moduleName = name; }; }));

  grocy = callPackage ./grocy { inherit mylibs composerEnv; };

  infcloud = callPackage ./infcloud {};

  mantisbt_2 = callPackage ./mantisbt_2 {};
  mantisbt_2-with-plugins = mantisbt_2.withPlugins (builtins.attrValues mantisbt_2-plugins);
  mantisbt_2-plugins = let
    names = [ "slack" "source-integration" ];
  in
    lib.attrsets.genAttrs names
      (name: callPackage (./mantisbt_2/plugins + "/${name}") {});

  mastodon = callPackage ./mastodon { inherit mylibs; };

  mediagoblin = callPackage ./mediagoblin { inherit mylibs; };
  mediagoblin-with-plugins = mediagoblin.withPlugins (builtins.attrValues mediagoblin-plugins);
  mediagoblin-plugins = let
    names = [ "basicsearch" ];
  in
    lib.attrsets.genAttrs names
      (name: callPackage (./mediagoblin/plugins + "/${name}") {});

  nextcloud = callPackage ./nextcloud {};
  nextcloud-with-apps = nextcloud.withPlugins (builtins.attrValues nextcloud-apps);
  nextcloud-apps = let
      names = [
        "audioplayer" "bookmarks" "calendar" "contacts" "deck"
        "files_markdown" "gpxedit" "gpxpod" "keeweb" "music"
        "notes" "ocsms" "passman" "spreed" "tasks"
        "flowupload" "carnet" "maps" "cookbook" "polls"
        "apporder" "extract" "files_readmemd" "metadata"
      ];
    in
    lib.attrsets.genAttrs names
      (name: callPackage (./nextcloud/apps + "/${name}.nix") { buildApp = nextcloud.buildApp; });

  peertube = callPackage ./peertube { inherit mylibs; };
  phpldapadmin = callPackage ./phpldapadmin {};
  rompr = callPackage ./rompr { inherit mylibs; };

  roundcubemail = callPackage ./roundcubemail {};
  roundcubemail-with-plugins-skins = roundcubemail.withPlugins (builtins.attrValues roundcubemail-plugins) (builtins.attrValues roundcubemail-skins);
  roundcubemail-skins = let
    names = [];
  in
    lib.attrsets.genAttrs names
      (name: callPackage (./roundcubemail/skins + "/${name}") {});
  roundcubemail-plugins = let
    names = [
      "automatic_addressbook" "carddav" "contextmenu"
      "contextmenu_folder" "html5_notifier" "ident_switch"
      "message_highlight" "thunderbird_labels"
    ];
  in
    lib.attrsets.genAttrs names
      (name: callPackage (./roundcubemail/plugins + "/${name}") { buildPlugin = roundcubemail.buildPlugin; });

  spip = callPackage ./spip {};
  taskwarrior-web = callPackage ./taskwarrior-web { inherit mylibs; };

  ttrss = callPackage ./ttrss { inherit mylibs; };
  ttrss-with-plugins = ttrss.withPlugins (builtins.attrValues ttrss-plugins);
  ttrss-plugins = let
    names = [ "auth_ldap" "af_feedmod" "feediron" "ff_instagram" "tumblr_gdpr_ua" ];
    patched = [ "af_feedmod" "feediron" ];
  in
    lib.attrsets.genAttrs names
      (name: callPackage (./ttrss/plugins + "/${name}") (
        { inherit mylibs; } //
        (if builtins.elem name patched then { patched = true; } else {})
        )
      );

  wallabag = callPackage ./wallabag { inherit composerEnv; };
  yourls = callPackage ./yourls { inherit mylibs; };
  yourls-with-plugins = yourls.withPlugins (builtins.attrValues yourls-plugins);
  yourls-plugins = let
    names = [ "ldap" ];
  in
    lib.attrsets.genAttrs names
      (name: callPackage (./yourls/plugins + "/${name}") { inherit mylibs; });
}
