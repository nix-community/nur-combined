{ bc, cantarell-fonts, fetchFromGitHub, lib, makeFontsConf, optipng, resvg
, runCommandLocal, sassc, stdenv

# A base16 theme configuration as defined in the `theme.base16` module.
, configBase16 ? {
  name = "Replace-Me";
  kind = "dark";
  colors = {
    base00.hex.rgb = "000000";
    base01.hex.rgb = "000000";
    base02.hex.rgb = "000000";
    base03.hex.rgb = "000000";
    base04.hex.rgb = "000000";
    base05.hex.rgb = "000000";
    base06.hex.rgb = "000000";
    base07.hex.rgb = "000000";
    base08.hex.rgb = "000000";
    base09.hex.rgb = "000000";
    base0A.hex.rgb = "000000";
    base0B.hex.rgb = "000000";
    base0C.hex.rgb = "000000";
    base0D.hex.rgb = "000000";
    base0E.hex.rgb = "000000";
    base0F.hex.rgb = "000000";
  };
} }:

let

  version = "20210322";

in stdenv.mkDerivation {
  pname = "materia-theme";
  inherit version;

  src = fetchFromGitHub {
    owner = "nana-4";
    repo = "materia-theme";
    rev = "v${version}";
    sha256 = "1fsicmcni70jkl4jb3fvh7yv0v9jhb8nwjzdq8vfwn256qyk0xvl";
  };

  nativeBuildInputs = [
    bc
    optipng
    sassc

    (runCommandLocal "rendersvg" { } ''
      mkdir -p $out/bin
      ln -s ${resvg}/bin/resvg $out/bin/rendersvg
    '')
  ];

  dontConfigure = true;

  # Fixes problem "Fontconfig error: Cannot load default config file"
  FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ cantarell-fonts ]; };

  theme = let inherit (configBase16) colors;
  in lib.generators.toKeyValue { } {
    # Color selection copied from
    # https://github.com/pinpox/nixos-home/blob/1cefe28c72930a0aed41c20d254ad4d193a3fa37/gtk.nix#L11
    ACCENT_BG = colors.base0B.hex.rgb;
    ACCENT_FG = colors.base00.hex.rgb;
    BG = colors.base00.hex.rgb;
    BTN_BG = colors.base02.hex.rgb;
    BTN_FG = colors.base06.hex.rgb;
    FG = colors.base05.hex.rgb;
    HDR_BG = colors.base02.hex.rgb;
    HDR_BTN_BG = colors.base01.hex.rgb;
    HDR_BTN_FG = colors.base05.hex.rgb;
    HDR_FG = colors.base05.hex.rgb;
    MATERIA_SURFACE = colors.base02.hex.rgb;
    MATERIA_VIEW = colors.base01.hex.rgb;
    MENU_BG = colors.base02.hex.rgb;
    MENU_FG = colors.base06.hex.rgb;
    SEL_BG = colors.base0D.hex.rgb;
    SEL_FG = colors.base0E.hex.rgb;
    TXT_BG = colors.base02.hex.rgb;
    TXT_FG = colors.base06.hex.rgb;
    WM_BORDER_FOCUS = colors.base05.hex.rgb;
    WM_BORDER_UNFOCUS = colors.base03.hex.rgb;

    MATERIA_COLOR_VARIANT = configBase16.kind;
    MATERIA_STYLE_COMPACT = "True";
    UNITY_DEFAULT_LAUNCHER_STYLE = "False";
  };

  passAsFile = [ "theme" ];

  postPatch = ''
    patchShebangs .

    sed -e '/handle-horz-.*/d' -e '/handle-vert-.*/d' \
      -i ./src/gtk-2.0/assets.txt
  '';

  buildPhase = ''
    export HOME="$NIX_BUILD_ROOT"
    ./change_color.sh \
       -i False \
       -t $out/share/themes \
       -o ${configBase16.name} \
       "$themePath"
  '';
}
