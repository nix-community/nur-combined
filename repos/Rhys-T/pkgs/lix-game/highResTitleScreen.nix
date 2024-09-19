{ lib, fetchurl, common }: fetchurl {
    name = "${common.pname}-mainmenubg-hires.png";
    url = "https://github.com/SimonN/LixD/assets/674969/937e6266-bad8-46f5-baef-ddef5378009c";
    hash = "sha256-BopSCjgHq6sBVeTZcIL49tABM3bDe6YYPjIt68i7I9s=";
    meta = common.meta // {
        description = "${common.meta.description} (high-resolution title screen artwork)";
        changelog = "https://github.com/SimonN/LixD/issues/128";
        license = lib.licenses.cc0;
    };
}
