{
  pkgs,
  lib ? pkgs.lib,
}:

let
  nixosEval = import <nixpkgs/nixos/lib/eval-config.nix>;
  config =
    (nixosEval {
      modules = [
        ../modules/typst.nix
      ];
    }).config;
  cfg = config.nagy.typst;
in
rec {

  mkTypst =
    { filename }:
    let
      filename2 =
        if lib.hasSuffix ".org" filename then mkTypstFromOrg { inherit filename; } else filename;
    in
    pkgs.runCommandLocal "document.pdf"
      {
        nativeBuildInputs = [
          cfg.package
        ];
        env.TYPST_FONT_PATHS = lib.makeSearchPath "share/fonts" config.fonts.packages;
      }
      ''
        typst compile ${filename2}/file.typ $out
      '';

  mkTypstFromOrg =
    { filename }:
    pkgs.runCommandLocal "document.typ"
      {
        nativeBuildInputs = [
          (pkgs.emacs.pkgs.withPackages (ps: [
            (ps.ox-typst.overrideAttrs (
              lib.optionalAttrs (lib.pathExists ~/ox-typst) {
                src = lib.cleanSource ~/ox-typst;
              }
            ))
          ]))
          pkgs.typstyle
        ];
        env = {
          # TYPST_FONT_PATHS = lib.makeSearchPath "share/fonts/openfont" config.fonts.packages;
          EMACS_ORG_TYPST_HEADLINE_OFFSET_BACKEND = pkgs.writeText "code.el" ''
            (org-export-define-derived-backend 'typst-headline-offset 'typst
              :translate-alist
              `((headline . ,(lambda (headline contents info)
                               (let* ((info (plist-put info :headline-offset 1)))
                                 (org-typst-headline headline contents info))
                               ))))
          '';
        };
      }
      (
        let
          orgBackend = if (lib.hasSuffix ".cv.org" filename) then "typst-headline-offset" else "typst";
        in
        ''
          cp ${filename} file.org
          emacs --batch \
            --load ox-typst \
            file.org \
            --load $EMACS_ORG_TYPST_HEADLINE_OFFSET_BACKEND \
            --eval "(org-export-to-file '${orgBackend} \"file.typ\")"
          typstyle --inplace file.typ
          install -Dm644 -t "$out" file.typ
        ''
      );

  convertOrgToTypst = pkgs.writeShellApplication {
    name = "convert-org-to-typst";
    passthru = {
      fromSuffix = ".org";
      toSuffix = ".typ";
    };
    runtimeInputs = [
      (pkgs.emacs.pkgs.withPackages (ps: [
        (ps.ox-typst.overrideAttrs (
          lib.optionalAttrs (lib.pathExists ~/ox-typst) {
            src = lib.cleanSource ~/ox-typst;
          }
        ))
      ]))
    ];
    runtimeEnv = {
      # TYPST_FONT_PATHS = lib.makeSearchPath "share/fonts/openfont" config.fonts.packages;
      EMACS_ORG_TYPST_HEADLINE_OFFSET_BACKEND = pkgs.writeText "code.el" ''
        (org-export-define-derived-backend 'typst-headline-offset 'typst
          :translate-alist
          `((headline . ,(lambda (headline contents info)
                           (let* ((info (plist-put info :headline-offset 1)))
                             (org-typst-headline headline contents info))
                           ))))
      '';
    };
    text = ''
      FILENAME="$1"; shift
      ORG_BACKEND=$([[ "$FILENAME" == *.cv.org ]] && echo "typst-headline-offset" || echo "typst")
      TMPFILE=$(mktemp --suffix=.typ)
      emacs -Q -nw --batch \
        --load ox-typst \
        --load "$EMACS_ORG_TYPST_HEADLINE_OFFSET_BACKEND" \
        "$FILENAME" \
        --eval "(org-export-to-file '$ORG_BACKEND \"$TMPFILE\")"
      typstyle --inplace "$TMPFILE"
      cat -- "$TMPFILE"
      # rm -v -- $TMPFILE
    '';
  };

}
