resolved: stable:

with import ./library/override-utils.lib.nix { inherit stable; nur = ./nur.nix; search = [ "unstable" "unstable-small" ]; };

let
  inherit (lib) findFirst hasInfix makeBinPath throwIf versionAtLeast versionOlder;
  inherit (stable) fetchurl lib;

  community-vscode-extensions = (import <community-vscode-extensions>).extensions.${stable.stdenv.hostPlatform.system}.forVSCodeVersion resolved.vscodium.version;
  open-vsx = { _name = "open-vsx"; vscode-extensions = community-vscode-extensions.open-vsx; };
  vscode-marketplace = { _name = "vscode-marketplace"; vscode-extensions = community-vscode-extensions.vscode-marketplace; };
in
specify {
  add-words = any;
  aegisub.overlay = a: throwIf (a.version != "3.4.2") "aegisub overlay is outdated" {
    version = "3.4.2-unstable-2025-12-01";
    src = a.src.override (_: { tag = null; rev = "1ad6844de46159a7db66da163992ddd598e1b9c7"; hash = "sha256-70qIs/MASVtQHl2580C3iv9Do2G9JNptGnpjk765L7A="; });
    postPatch = a.postPatch + "patchShebangs 'tools/combine-config.py'";
  }; # Pending TypesettingTools/Aegisub#309 via ≥3.5
  affine-font = any;
  ai-robots-txt = any;
  album-art = any;
  ansible-lint.broken = a: versionOlder (findFirst (p: p.pname == "ansible-compat") null a.passthru.dependencies).version "25.8"; # NixOS/nixpkgs#460422
  ansible-vault-pass-client = any;
  apex = any;
  attachments = any;
  aws-sam-cli = { version = "≠1.143.0"; } /* NixOS/nixpkgs#459334 */ // { broken = a: versionAtLeast "1.154.0" a.version && versionAtLeast (findFirst (p: p.pname == "ruamel-yaml") null a.passthru.dependencies).version "0.19"; } /* https://hydra.nixos.org/build/322100022 */;
  blocky-ui = any;
  busyserve = any;
  caddy-with-cache-route53 = any;
  cavif = any;
  ch57x-keyboard-tool = any;
  chunker.dontEval = true /* FIXME: infinite recursion */;
  chromium.commandLineArgs = "--enable-features=WaylandTextInputV3"; # Pending https://crbug.com/40272818, NixOS/nixpkgs#394395
  co2monitor = any;
  constrict = any;
  darktable.version = "≥5.4"; # 5.2 was freezing 🤷
  dawarich.patch = ./library/assets/dawarich_viridis.patch;
  decompiler-mc = any;
  dmarc-report-converter = any;
  dmarc-report-notifier.search = pin "a82ccc39b39b621151d6732718e3e250109076fa" "sha256-gf2AmWVTs8lEq7z/3ZAsgnZDhWIckkb+ZnAo5RzSxJg="; # Pending https://github.com/domainaware/parsedmarc/commit/dd9ef90773d4bdd00da63bc987fb3d45a07e08dd#commitcomment-178034508
  easy-timeline = any;
  email-hash = any;
  emote.overlay = e: { postInstall = e.postInstall or "" + "\nsubstituteInPlace $out/share/applications/com.tomjwatson.Emote.desktop --replace-fail 'Exec=emote' \"Exec=$out/bin/emote\""; }; # Allow desktop entry as entrypoint
  espressif-serial = any;
  fastnbt-tools = any;
  fediblockhole = any;
  filter-imf = any;
  firefox.overlay = w: { makeWrapperArgs = w.makeWrapperArgs ++ [ "--unset" "LC_TIME" ]; }; # Workaround for bugzilla#1269895
  freecad.env.GSETTINGS_SCHEMA_DIR = "${resolved.gtk3}/share/gsettings-schemas/${resolved.gtk3.name}/glib-2.0/schemas"; # Workaround for NixOS/nixpkgs#467783
  fstl.condition = f: hasInfix "xdg_install" f.postInstall or ""; # Pending NixOS/nixpkgs#489682
  git-diff-image = any;
  git-diff-minecraft = any;
  git-remote = any;
  gnome-shell = { patch = [ ./library/assets/gnome-shell_accent-color.patch ./library/assets/gnome-shell_screenshot-location.patch ]; ccache = true; }; # Pending GNOME/gnome-shell#5370
  gnomeExtensions.launcher.patch = [ ./library/assets/gnome-extension-launcher_icon.patch ./library/assets/gnome-extension-launcher_hide-settings.patch ];
  gopass-await = any;
  gopass-env = any;
  gopass-ydotool = any;
  gpx-reduce = any;
  graalvmPackages.graaljs.overlay = g: throwIf (hasInfix "jvm" g.src.url) "graaljs no longer requires an overlay" { src = fetchurl { url = builtins.replaceStrings [ "community" ] [ "community-jvm" ] g.src.url; hash = ({ "24.2.2" = "sha256-LDuMh4hhJSbKb8m5DSH8/tcb8rxiRG6FKS5okcUn2JY="; "25.0.2" = "sha256-HutawQBIbMSU+M7xe8C6nBsxoIi6Kz1O0weSvR9LeIk="; }).${g.version}; }; buildInputs = g.buildInputs ++ stable.graalvmPackages.graalvm-ce.buildInputs; }; # https://discourse.nixos.org/t/36314
  graalvmPackages.graalvm-ce.overlay = g: throwIf (hasInfix "font" g.preFixup) "graalvm-ce no longer requires an overlay" { preFixup = g.preFixup + "\nfind \"$out\" -name libfontmanager.so -exec patchelf --add-needed libfontconfig.so {} \\;"; }; # Workaround for https://github.com/NixOS/nixpkgs/pull/215583#issuecomment-1615369844
  htop.patch = ./library/assets/htop_colors.patch; # htop-dev/htop#1416
  incremental-compress = any;
  inkscape = { patch = ./library/assets/inkscape_png-no-comment.patch; ccache = true; dontEval = true /* FIXME: infinite recursion */; }; # Pending inkscape/inkscape!7193
  inkscape-extensions.applytransforms.broken = a: let libxml2 = (findFirst (p: p ? pname && p.pname == "libxml2") null (findFirst (p: p.pname == "lxml") null (findFirst (p: p.pname == "inkex") null a.nativeCheckInputs).passthru.dependencies).nativeBuildInputs); in libxml2 != null && versionAtLeast libxml2.version "2.15"; # Workaround for inkscape/extensions#617 (https://hydra.nixos.org/build/314374425) pending NixOS/nixpkgs#483120
  iosevka-custom = any;
  iptables_exporter = any;
  jj-dynamic-default-description = any;
  josm = { jre = resolved.graalvmPackages.graalvm-ce; extraJavaOpts = "--module-path=${resolved.graalvmPackages.graaljs}/modules"; }; # josm-scripting-plugin
  josm-imagery-used = any;
  journal-brief = any;
  jujutsu.version = "≥0.36";
  just-local = any;
  kitty.patch = ./library/assets/kitty_paperwm.patch; # Workaround for paperwm/PaperWM#943
  little-a-map = any;
  llmfit.version = "≥0.8.5"; # AlexsJones/llmfit#230
  losslesscut-bin.args = [ "--disable-networking" ];
  mark-applier = any;
  may-upgrade = any;
  meshtastic-url = any;
  minemap = any;
  mozjpeg-simple = any;
  nbt-explorer = any;
  nix-preview = any;
  nom-wrappers = any;
  numbat.version = "≥1.23"; # sharkdp/numbat#825
  off = any;
  office-hours = any;
  oxvg = any;
  pdfalyzer = any;
  picard.overlay = p: { preFixup = p.preFixup + "\nmakeWrapperArgs+=(--prefix PATH : ${makeBinPath [ resolved.rsgain ]})"; }; # NixOS/nixpkgs#255222
  pngquant-interactive = any;
  python39.search = pin "f62d6734af4581af614cab0f2aa16bcecfc33c11" "sha256-DlWElYYHKaUsGX/pfyIUO8aQHCPAia1THVR0RbtCJQ0=";
  pythonPackages.busylight-core.patch = ./library/assets/busylight-core_led-mask.patch;
  pythonPackages.busylight-for-humans.patch = ./library/assets/busylight-for-humans_fix-speed.patch; # Pending ≥0.45.3
  signal-desktop.args = [ "--use-tray-icon" ];
  smartcut = any;
  snitch = any;
  spf-check = any;
  spf-tree = any;
  starship-jj = any;
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
    jjk.jjk = any;
    jnbt.vscode-rufo.search = open-vsx;
    joaompinto.vscode-graphviz.search = open-vsx;
    kdl-org.kdl.search = [ open-vsx vscode-marketplace ];
    kokakiwi.vscode-just.search = open-vsx;
    leighlondon.eml.search = [ open-vsx vscode-marketplace ];
    loriscro.super.search = open-vsx;
    mitchdenny.ecdc.search = open-vsx;
    ms-vscode.wasm-wasi-core.search = open-vsx;
    ronnidc.nunjucks.search = [ open-vsx vscode-marketplace ];
    sissel.shopify-liquid.search = open-vsx;
    syler.sass-indented.search = open-vsx;
    sysoev.language-stylus.search = open-vsx;
    volkerdobler.insertnums.search = open-vsx;
    webfreak.advanced-local-formatters.search = open-vsx;
    ybaumes.highlight-trailing-white-spaces.search = open-vsx;
  };
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
