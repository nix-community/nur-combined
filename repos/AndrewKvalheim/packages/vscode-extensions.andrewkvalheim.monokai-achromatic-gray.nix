{ lib
, vscode-utils
, writers

  # Dependencies
, jaq
, moreutils
, vscodium

  # Parameters
, blackLevel ? null
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
    from os import environ

    v1 = 255 * float(environ.get("BLACK", "0"))


    def adjust(v0):
        def adjust_(_, dict, key, css):
            h, s, v, a = css_to_hsva(css)

            if s != 0 and s < 0.2:
                v_ = v1 + (v - v0) * (127 - v0) / (127 - v1) if v < 127 else v
                a_hex = "" if a == 255 else "%02x" % (a)
                css_ = "#%02x%02x%02x%s" % (*hsv_to_rgb(h, 0, round(v_)), a_hex)

                stderr.write(f"Adjust {css} → {css_} ({key})\n")
                dict[key] = css_

        return adjust_


    def css_to_hsva(css):
        if not css[0] == "#":
            raise NotImplementedError(f"Not implemented for {css}")

        r, g, b = int(css[1:3], 16), int(css[3:5], 16), int(css[5:7], 16)
        a = int(css[7:9], 16) if css[7:9] else 255

        return *rgb_to_hsv(r, g, b), a


    def darkest(v_min, dict, key, css):
        h, s, v, a = css_to_hsva(css)
        return v if v_min is None or a == 255 and v < v_min else v_min


    def fold_colors(theme, f, result=None):
        for k, v in theme["colors"].items():
            result = f(result, theme["colors"], k, v)

        for rule in theme["tokenColors"]:
            for k, v in rule["settings"].items():
                if k in ["foreground"]:
                    result = f(result, rule["settings"], k, v)

        return result


    theme = json.load(stdin)
    fold_colors(theme, adjust(fold_colors(theme, darkest)))
    print(json.dumps(theme))
  '';
in
vscode-utils.buildVscodeExtension (extension: {
  name = "monokai-achromatic-gray";
  pname = extension.name; # TODO: Why is it necessary to set both name and pname?
  version = vscodium.version;

  vscodeExtPublisher = "andrewkvalheim";
  vscodeExtName = extension.name;
  vscodeExtUniqueId = "${extension.vscodeExtPublisher}.${extension.vscodeExtName}";

  src = vscodium + /lib/vscode/resources/app/extensions/theme-monokai;

  preUnpack = "sourceRoot='theme-monokai'"; # Override hard coding of buildVscodeExtension

  nativeBuildInputs = [ jaq moreutils ];

  BLACK = blackLevel;

  postPatch = ''
    jaq --in-place ${escapeShellArg patchPackage} 'package.json'
    jaq --in-place ${escapeShellArg patchPackageNls} 'package.nls.json'
    <'themes/monokai-color-theme.json' ${patchTheme} | sponge 'themes/monokai-color-theme.json'
  '';
})
