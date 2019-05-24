{ buildApp }:
buildApp rec {
  appName = "carnet";
  version = "0.15.2";
  url = "https://github.com/PhieF/CarnetNextcloud/releases/download/v${version}/${appName}-nc-v${version}.tar.gz";
  sha256 = "1npjb2bgwcfxlf22ygl2hfhfgaigk1kpdk795yc79mx2l1iicmg0";
}
