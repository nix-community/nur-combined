resolved: stable:

with import ../packages/override-utils.nix { inherit stable; };

let
  community-vscode-extensions = (import <community-vscode-extensions>).extensions.${stable.system}.forVSCodeVersion resolved.vscodium.version;
  open-vsx = { _name = "open-vsx"; vscode-extensions = community-vscode-extensions.open-vsx; };
  vscode-marketplace = { _name = "vscode-marketplace"; vscode-extensions = community-vscode-extensions.vscode-marketplace; };
in
(specify {
  add-words = any;
  affine-font = any;
  album-art = any;
  ansible-vault-pass-client = any;
  apex = any;
  attachments = any;
  audacity.env.GDK_BACKEND = "x11"; # NixOS/nixpkgs#238910
  buildJosmPlugin = any;
  cavif = any;
  ch57x-keyboard-tool = any;
  chromium.commandLineArgs = "--enable-features=WaylandTextInputV3"; # Pending https://crbug.com/40272818
  co2monitor = any;
  decompiler-mc = any;
  dmarc-report-converter = any;
  dmarc-report-notifier = any;
  email-hash = any;
  emote.overlay = e: { postInstall = e.postInstall or "" + "\nsubstituteInPlace $out/share/applications/com.tomjwatson.Emote.desktop --replace-fail 'Exec=emote' \"Exec=$out/bin/emote\""; }; # Allow desktop entry as entrypoint
  espressif-serial = any;
  fastnbt-tools = any;
  fediblockhole = any;
  firefox.overlay = w: { buildCommand = w.buildCommand + "\nwrapProgram $executablePath --unset LC_TIME"; }; # Workaround for bugzilla#1269895
  git-diff-image = any;
  git-diff-minecraft = any;
  git-remote = any;
  gnome-shell.patch = ../packages/resources/gnome-shell_screenshot-location.patch; # Pending GNOME/gnome-shell#5370
  gopass-await = any;
  gopass-env = any;
  gopass-ydotool = any;
  gpx-reduce = any;
  graalvm-ce.overlay = g: stable.lib.throwIf (stable.lib.hasInfix "font" g.preFixup) "graalvm-ce no longer requires an overlay" { preFixup = g.preFixup + "\nfind \"$out\" -name libfontmanager.so -exec patchelf --add-needed libfontconfig.so {} \\;"; }; # Workaround for https://github.com/NixOS/nixpkgs/pull/215583#issuecomment-1615369844
  graalvmCEPackages.graaljs.overlay = g: stable.lib.throwIf (stable.lib.hasInfix "jvm" g.src.url) "graaljs no longer requires an overlay" { src = stable.fetchurl { url = builtins.replaceStrings [ "community" ] [ "community-jvm" ] g.src.url; hash = "sha256-XQpE7HfUVc0ak7KY+6ONu9cbFjlocKGbUPNlWKdTnM0="; }; buildInputs = g.buildInputs ++ stable.graalvm-ce.buildInputs; }; # https://discourse.nixos.org/t/36314
  gtk4-icon-browser = any;
  htop.patch = ../packages/resources/htop_colors.patch; # htop-dev/htop#1416
  httpie.env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"; # NixOS/nixpkgs#94666
  ios-safari-remote-debug-kit = any;
  ios-webkit-debug-proxy = any;
  iosevka-custom = any;
  iptables_exporter = any;
  josm = { jre = resolved.graalvm-ce; extraJavaOpts = "--module-path=${resolved.graalvmCEPackages.graaljs}/modules"; }; # josm-scripting-plugin
  josm-hidpi = any;
  josm-imagery-used = any;
  just-local = any;
  little-a-map = any;
  losslesscut-bin.args = [ "--disable-networking" ];
  mark-applier = any;
  meshtastic-matrix-relay.python3Packages = stable.python3Packages.override {
    overrides = resolvedPythonPackages: pythonPackages: {
      py-staticmaps = stable.lib.throwIf (pythonPackages ? py-staticmaps) "python3Packages.py-staticmaps no longer requires packaging" (pythonPackages.buildPythonPackage rec {
        pname = "py-staticmaps";
        version = "0.4.0";
        pyproject = true;
        src = pythonPackages.fetchPypi { inherit pname version; hash = "sha256-Wrpa1Z8wpj+GDnbtmUB6bvsk6q1ciZeqhhc2OYnxc4k="; };
        build-system = with pythonPackages; [ setuptools ];
        dependencies = with resolvedPythonPackages; [ appdirs geographiclib pillow python-slugify requests s2sphere svgwrite ];
      });
      s2sphere = stable.lib.throwIf (pythonPackages ? s2sphere) "python3Packages.s2sphere no longer requires packaging" (pythonPackages.buildPythonPackage rec {
        pname = "s2sphere";
        version = "0.2.5";
        pyproject = true;
        src = pythonPackages.fetchPypi { inherit pname version; hash = "sha256-wkeMH/fGAaWacVGle2BUNYl1FFePpr24cwchwYKtu68="; };
        build-system = with pythonPackages; [ setuptools ];
        dependencies = with resolvedPythonPackages; [ future ];
      });
    };
  };
  minemap = any;
  mmdbinspect = any;
  mozjpeg-simple = any;
  nbt-explorer = any;
  nix-preview = any;
  off = any;
  picard.overlay = p: { preFixup = p.preFixup + "\nmakeWrapperArgs+=(--prefix PATH : ${stable.lib.makeBinPath [ resolved.rsgain ]})"; }; # NixOS/nixpkgs#255222
  pngquant-interactive = any;
  signal-desktop.gappsWrapperArgs = "--add-flags --use-tray-icon"; # Enable tray icon
  spf-check = any;
  spf-tree = any;
  tile-stitch = any;
  unln = any;
  vagrant.withLibvirt = false; # Workaround for NixOS/nixpkgs#348938
  vscode-extensions = namespaced {
    bpruitt-goddard.mermaid-markdown-syntax-highlighting.search = open-vsx;
    compilouit.xkb.search = open-vsx;
    csstools.postcss.search = open-vsx;
    earshinov.permute-lines.search = open-vsx;
    earshinov.simple-alignment.search = open-vsx;
    eseom.nunjucks-template.search = open-vsx;
    exiasr.hadolint.search = open-vsx;
    fabiospampinato.vscode-highlight.search = open-vsx;
    flowtype.flow-for-vscode = { version = "≥2.2.1"; search = [ open-vsx vscode-marketplace ]; };
    jnbt.vscode-rufo.search = open-vsx;
    joaompinto.vscode-graphviz.search = open-vsx;
    kokakiwi.vscode-just.search = open-vsx;
    leighlondon.eml.search = [ open-vsx vscode-marketplace ];
    loriscro.super.search = [ open-vsx ];
    mitchdenny.ecdc.search = open-vsx;
    ms-vscode.wasm-wasi-core.search = [ open-vsx ];
    ronnidc.nunjucks.search = [ open-vsx vscode-marketplace ];
    silvenon.mdx.search = open-vsx;
    sissel.shopify-liquid.search = open-vsx;
    syler.sass-indented.search = open-vsx;
    theaflowers.qalc.search = open-vsx;
    volkerdobler.insertnums.search = [ open-vsx vscode-marketplace ];
    ybaumes.highlight-trailing-white-spaces.search = open-vsx;
  };
  whipper = {
    condition = w: w.dontWrapGApps or false; # NixOS/nixpkgs#316717
    patch = [ ../packages/resources/whipper_flac-level.patch ../packages/resources/whipper_speed.patch ../packages/resources/whipper_detect-tty.patch ];
  };
  ydotool.patch = ../packages/resources/ydotool-halmakish.patch; # Pending ReimuNotMoe/ydotool#177
  yubikey-touch-detector.overlay = y: {
    postPatch = y.postPatch or "" + ''substituteInPlace notifier/libnotify.go --replace-fail \
      'AppIcon: "yubikey-touch-detector"' \
      'AppIcon: "'"$out"'/share/icons/hicolor/128x128/apps/yubikey-touch-detector.png"'
    '';
  };
  zsh-abbr.condition = z: !z.meta.unfree;
  zsh-click = any;
}) // {
  fetchsvn = a: (stable.fetchsvn a).overrideAttrs (f: stable.lib.throwIf (builtins.any (p: p.pname == "nss-cacert") f.nativeBuildInputs) "fetchsvn no longer requires an override" { nativeBuildInputs = f.nativeBuildInputs ++ [ resolved.cacert ]; }); # Pending NixOS/nixpkgs#356829
}
