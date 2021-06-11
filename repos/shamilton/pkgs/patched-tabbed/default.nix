{ tabbed
, fetchFromGitHub
, libbsd
}:
(tabbed.override {
  patches = [ ./keys.patch ];
}).overrideAttrs (old: {
  name = "tabbed-20180310-patched";
  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "tabbed";
    rev = "823e2981830be93aa68e2aba7f3b1e13f2e6e0c0";
    sha256 = "1w6zzf86wnx6dymgfi0samrxgwl23z1ghnd2gv3gv25kvwp72vxy";
  };
  buildInputs = (old.buildInputs or []) ++ [ libbsd ];
})
