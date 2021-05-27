{ version, sha256 }:
{ fetchurl }:
let 
  intel-sgx-path = "https://download.01.org/intel-sgx/";
in fetchurl {
  url =
    "${intel-sgx-path}/sgx-dcap/${version}/linux/prebuilt_dcap_${version}.tar.gz";
  inherit sha256;
}

