{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "office.yazi";
    version = "0-unstable-2025-09-20";

    src = fetchFromGitHub {
        owner = "macydnah";
        repo = "office.yazi";
        rev = "41ebef8be9dded98b5179e8af65be71b30a1ac4d";
        hash = "sha256-QFto48D+Z8qHl7LHoDDprvr5mIJY8E7j37cUpRjKdNk=";
    };
    meta = {
        description = "Office documents previewer plugin for Yazi, using libreoffice (compatible with .docx, .xlsx, .pptx, .odt, .ods, .odp; and other file formats supported by the Office Open XML and OpenDocument standards";
        homepage = "https://github.com/macydnah/office.yazi";
        license = lib.licenses.mit;
    };
}
