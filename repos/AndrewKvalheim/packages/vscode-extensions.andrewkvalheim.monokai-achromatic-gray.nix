{ lib
, vscode-utils
, writers

  # Dependencies
, jaq
, moreutils
, vscodium
}:

let
  inherit (lib) escapeShellArg;
  inherit (writers) writePython3;

  patchPackage = ''
    .name = "\(.name)-achromatic-gray" |
    .contributes.themes[0].id = "\(.contributes.themes[0].id) Achromatic Gray"
  '';

  patchPackageNls = ''
    .themeLabel = "\(.themeLabel) Achromatic Gray" |
    .displayName = (.displayName | sub("(?<s> Theme)?$"; " Achromatic Gray\(.s)")) |
    .description = "Monokai theme modified to use achromatic grays"
  '';

  patchTheme = writePython3 "vscode-extension-monokai-achromatic-gray-patch-theme" { } ''
    from colorsys import hsv_to_rgb, rgb_to_hsv
    import json
    from sys import stderr, stdin


    def process(dict, keys=None, prefix=""):
        for key, css in dict.items():
            if keys and key not in keys:
                continue

            if not css[0] == "#":
                raise NotImplementedError(f"Not implemented for {css}")
            r, g, b = int(css[1:3], 16), int(css[3:5], 16), int(css[5:7], 16)
            h, s, v = rgb_to_hsv(r, g, b)

            if s != 0 and s < 0.2:
                desaturated = "#%02x%02x%02x%s" % (*hsv_to_rgb(h, 0, v), css[7:9])
                stderr.write(f"Desaturate {css} → {desaturated} ({prefix}{key})\n")
                dict[key] = desaturated


    theme = json.load(stdin)

    process(theme["colors"])
    for rule in theme["tokenColors"]:
        process(rule["settings"], keys=["foreground"], prefix="token.")

    print(json.dumps(theme))
  '';
in
vscode-utils.buildVscodeExtension rec {
  name = "monokai-achromatic-gray";
  version = vscodium.version;

  vscodeExtPublisher = "andrewkvalheim";
  vscodeExtName = name;
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

  src = vscodium + /lib/vscode/resources/app/extensions/theme-monokai;

  preUnpack = "sourceRoot='theme-monokai'"; # Override hard coding of buildVscodeExtension

  nativeBuildInputs = [ jaq moreutils ];

  postPatch = ''
    jaq --in-place ${escapeShellArg patchPackage} 'package.json'
    jaq --in-place ${escapeShellArg patchPackageNls} 'package.nls.json'
    <'themes/monokai-color-theme.json' ${patchTheme} | sponge 'themes/monokai-color-theme.json'
  '';
}
