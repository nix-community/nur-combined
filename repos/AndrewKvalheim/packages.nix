resolved: stable:

with import ./library/override-utils.lib.nix { inherit stable; nur = ./nur.nix; search = [ "unstable" "unstable-small" ]; };

let
  inherit (lib) makeBinPath throwIf;
  inherit (stable) lib;

  community-vscode-extensions = (import <community-vscode-extensions>).extensions.${stable.stdenv.hostPlatform.system}.forVSCodeVersion resolved.vscodium.vscodeVersion;
  open-vsx = { _name = "open-vsx"; vscode-extensions = community-vscode-extensions.open-vsx; };
  vscode-marketplace = { _name = "vscode-marketplace"; vscode-extensions = community-vscode-extensions.vscode-marketplace; };
in
specify {
  "3mf-thumbnailer" = any;
  add-words = any;
  aegisub.overlay = a: throwIf (a.version != "3.4.2") "aegisub overlay is outdated" {
    version = "3.4.2-unstable-2025-12-01";
    src = a.src.override (_: { tag = null; rev = "1ad6844de46159a7db66da163992ddd598e1b9c7"; hash = "sha256-70qIs/MASVtQHl2580C3iv9Do2G9JNptGnpjk765L7A="; });
    postPatch = a.postPatch + "patchShebangs 'tools/combine-config.py'";
  }; # Pending TypesettingTools/Aegisub#309 via ≥3.5
  affine-font = any;
  ai-robots-txt = any;
  album-art = any;
  ansible-vault-pass-client = any;
  apex = any;
  attachments.deps = { inherit (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/303bd8071377433a2d8f76e684ec773d70c5b642.tar.gz") { config.allowUnfree = true; overlays = [ ]; }) yarn2nix-moretea; }; # TODO: Migrate
  blocky-ui = any;
  busyserve = any;
  caddy-with-cache-route53 = any;
  cc-icons-unicode = any;
  ch57x-keyboard-tool = any;
  chromium.commandLineArgs = "--enable-features=WaylandTextInputV3"; # Pending https://crbug.com/40272818, NixOS/nixpkgs#394395
  chunker.dontEval = true /* FIXME: infinite recursion */;
  co2monitor = any;
  darktable.version = "≥5.6"; # color harmonizer module
  dawarich.patch = ./library/assets/dawarich_viridis.patch;
  decompiler-mc = any;
  dmarc-report-converter = any;
  dmarc-report-notifier = any;
  easy-timeline = any;
  efficient-compression-tool.broken = e: e.version == "0.9.5" && ! e ? patches; # Pending NixOS/nixpkgs#517041
  email-hash = any;
  emote.overlay = e: { postInstall = e.postInstall or "" + "\nsubstituteInPlace $out/share/applications/com.tomjwatson.Emote.desktop --replace-fail 'Exec=emote' \"Exec=$out/bin/emote\""; }; # Allow desktop entry as entrypoint
  espressif-serial = any;
  fastnbt-tools = any;
  fediblockhole = any;
  filter-imf = any;
  firefox.overlay = w: { makeWrapperArgs = w.makeWrapperArgs ++ [ "--unset" "LC_TIME" ]; }; # Workaround for bugzilla#1269895
  freecad.env.GSETTINGS_SCHEMA_DIR = "${resolved.gtk3}/share/gsettings-schemas/${resolved.gtk3.name}/glib-2.0/schemas"; # Workaround for NixOS/nixpkgs#467783
  git-diff-image = any;
  git-diff-minecraft = any;
  git-remote = any;
  gnome-shell = { patch = [ ./library/assets/gnome-shell_accent-color.patch ./library/assets/gnome-shell_screenshot-location.patch ]; ccache = true; }; # Pending GNOME/gnome-shell#5370
  gnomeExtensions.launcher.patch = [ ./library/assets/gnome-extension-launcher_icon.patch ./library/assets/gnome-extension-launcher_hide-settings.patch ./library/assets/gnome-extension-launcher_gnome-50.patch /* Pending hedgieinsocks/gnome-extension-launcher#14 */ ];
  gopass-await = any;
  gopass-env = any;
  gopass-ydotool = any;
  gpx-reduce = any;
  htop.patch = ./library/assets/htop_colors.patch; # htop-dev/htop#1416
  incremental-compress = any;
  inkscape = { patch = ./library/assets/inkscape_png-no-comment.patch; ccache = true; dontEval = true /* FIXME: infinite recursion */; }; # inkscape/inkscape!7193
  iosevka-custom = any;
  iptables_exporter = any;
  jj-dynamic-default-description = any;
  josm-imagery-used = any;
  journal-brief = any;
  just-local = any;
  kitty.patch = ./library/assets/kitty_paperwm.patch; # Workaround for paperwm/PaperWM#943
  libgtop.patch = ./library/assets/libgtop_ignores.patch; # Workaround for GNOME/gnome-system-monitor#342
  little-a-map = any;
  losslesscut-bin.args = [ "--disable-networking" ];
  mark-applier = any;
  may-upgrade = any;
  meshtastic-url = any;
  minemap = any;
  mozjpeg-simple = any;
  nbt-explorer = any;
  nix-preview = any;
  nom-wrappers = any;
  off = any;
  office-hours = any;
  oxvg = any;
  pdfalyzer = any;
  picard.overlay = p: { preFixup = p.preFixup + "\nmakeWrapperArgs+=(--prefix PATH : ${makeBinPath [ resolved.rsgain ]})"; }; # NixOS/nixpkgs#255222
  pngquant-interactive = any;
  python39.search = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f62d6734af4581af614cab0f2aa16bcecfc33c11.tar.gz") { overlays = [ ]; };
  pythonPackages.busylight-core.patch = ./library/assets/busylight-core_led-mask.patch;
  qgis.env.GSETTINGS_SCHEMA_DIR = "${resolved.gtk3}/share/gsettings-schemas/${resolved.gtk3.name}/glib-2.0/schemas"; # Workaround for NixOS/nixpkgs#528925
  signal-desktop.args = [ "--use-tray-icon" ];
  sort-domains = any;
  spf-check = any;
  spf-tree = any;
  stretch-break = any;
  tile-stitch = any;
  udon = any;
  unln = any;
  vscode-extensions = namespaced {
    andrewkvalheim.monokai-achromatic-gray = any;
    bpruitt-goddard.mermaid-markdown-syntax-highlighting.search = open-vsx;
    compilouit.xkb.search = open-vsx;
    csstools.postcss.search = open-vsx;
    earshinov.permute-lines.search = open-vsx;
    earshinov.simple-alignment.search = open-vsx;
    eseom.nunjucks-template.search = open-vsx;
    exiasr.hadolint.search = open-vsx;
    fabiospampinato.vscode-highlight.search = open-vsx;
    flowtype.flow-for-vscode = { version = "≥2.2.1"; search = [ open-vsx vscode-marketplace ]; };
    jacobpfeifer.pfeifer-hurl.search = open-vsx;
    jnbt.vscode-rufo.search = open-vsx;
    joaompinto.vscode-graphviz.search = open-vsx;
    kdl-org.kdl.search = [ open-vsx vscode-marketplace ];
    kokakiwi.vscode-just.search = open-vsx;
    leighlondon.eml.search = [ open-vsx vscode-marketplace ];
    loriscro.super.search = open-vsx;
    mitchdenny.ecdc.search = open-vsx;
    ms-python.isort.version = "≥2026.5"; # microsoft/vscode-isort#649
    ms-vscode.wasm-wasi-core.search = open-vsx;
    ronnidc.nunjucks.search = [ open-vsx vscode-marketplace ];
    sissel.shopify-liquid.search = open-vsx;
    syler.sass-indented.search = open-vsx;
    sysoev.language-stylus.search = open-vsx;
    volkerdobler.insertnums.search = open-vsx;
    webfreak.advanced-local-formatters.search = open-vsx;
    ybaumes.highlight-trailing-white-spaces.search = open-vsx;
  };
  wayback-machine-archiver.version = "≥3.1"; # SPN2 API
  whipper.patch = [ ./library/assets/whipper_flac-level.patch ./library/assets/whipper_speed.patch ./library/assets/whipper_detect-tty.patch ];
  wireguard-vanity-address = any;
  ydotool.patch = ./library/assets/ydotool-engramish.patch; # Pending ReimuNotMoe/ydotool#177
  yubikey-touch-detector.overlay = y: {
    postPatch = y.postPatch or "" + ''substituteInPlace notifier/libnotify.go --replace-fail \
      'AppIcon: "yubikey-touch-detector"' \
      'AppIcon: "'"$out"'/share/icons/hicolor/128x128/apps/yubikey-touch-detector.png"'
    '';
  };
  zsh-abbr.condition = z: !z.meta.unfree;
  zsh-click = any;
}
