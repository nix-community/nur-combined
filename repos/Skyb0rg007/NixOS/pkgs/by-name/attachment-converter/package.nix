{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  ocaml,
  ocaml-ng,
  versionCheckHook,
  makeWrapper,
  libreoffice,
  pandoc,
  vips,
  ghostscript,
  poppler-utils,
}:
let
  baseOcamlPackages = ocaml-ng.ocamlPackages_4_14;
  ocamlPackages = baseOcamlPackages.overrideScope (
    self: super: {
      prettym = super.prettym.overrideAttrs (oldAttrs: {
        name = "ocaml${super.ocaml.version}-prettym-0.0.5";
        version = "0.0.5";
        src = fetchurl {
          url = "https://github.com/dinosaure/prettym/releases/download/0.0.5/prettym-0.0.5.tbz";
          hash = "sha256-2sFZmW8HqSTF9UQZU6lcxipLX17txJwxZZIRr/CT1GI=";
        };
        propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ self.bstr ];
      });
      keith-prelude = self.callPackage ./keith-prelude.nix { };
    }
  );
in
ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "attachment-converter";
  version = "0.2.2";

  minimalOCamlVersion = "4.14";

  src = fetchFromGitHub {
    owner = "uchicago-library";
    repo = "attachment-converter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J2C6cDwGh3cEE+4B+ziYtfbxvkAZ/JHxetJ+AD7gnaQ=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  postPatch = ''
    substituteInPlace dune --replace-fail "-ccopt -static" ""
    substituteInPlace lib/configuration.ml \
      --replace-fail "/usr/lib/attachment-converter/scripts/" \
                     "$out/lib/attachment-converter/scripts/"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    ocamlPackages.cmdliner
    ocamlPackages.keith-prelude
    ocamlPackages.mrmime
    ocamlPackages.ocamlnet
    ocamlPackages.prettym
    ocamlPackages.re
  ];

  postInstall = ''
    patchShebangs ./conversion-scripts/*.sh
    install -d $out/lib/attachment-converter/scripts
    install -m 755 ./conversion-scripts/*.sh $out/lib/attachment-converter/scripts
    wrapProgram $out/bin/attc \
      --prefix PATH : ${
        lib.makeBinPath [
          libreoffice
          pandoc
          vips
          ghostscript
          poppler-utils
        ]
      }
  '';

  meta = {
    homepage = "https://dldc.lib.uchicago.edu/open/attachment-converter/";
    description = "Tool for converting email attachments' formats";
    license = lib.licenses.gpl3Plus;
    mainProgram = "attc";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
