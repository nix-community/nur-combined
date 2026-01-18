{
  lib,
  mkZoteroAddon,
  fetchurl,
}:
mkZoteroAddon rec {
  pname = "Better BibTeX for Zotero";
  version = "7.0.76";

  src = fetchurl {
    url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v${version}/zotero-better-bibtex-${version}.xpi";
    hash = "sha256-Vp9UIeKBhG8w7WZhw8i6mISD4byZMLWhQQLO9KOysBE=";
  };

  addonId = "better-bibtex@iris-advies.com";

  meta = {
    description = "Make Zotero effective for us LaTeX holdouts";
    homepage = "https://github.com/retorquere/zotero-better-bibtex";
    license = lib.licenses.mit;
  };
}