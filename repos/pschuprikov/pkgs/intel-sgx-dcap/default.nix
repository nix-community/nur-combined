{ stdenv, fetchFromGitHub, file, intelSGXPackages, intelSGXDCAPPrebuilt
, coreutils }:
stdenv.mkDerivation rec {
  version = "1.4";
  name = "dcap-${version}";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "SGXDataCenterAttestationPrimitives";
    rev = "DCAP_${version}";
    sha256 = "5wbesfSi9KwB4KiOqLLrWFdqtrvC1Ug51azNPVtbl9M=";
  };

  buildInputs = [ file ];

  patchPhase = ''
    tar -xzvf ${intelSGXDCAPPrebuilt} -C QuoteGeneration
    substituteInPlace QuoteGeneration/buildenv.mk \
      --replace /bin/cp ${coreutils}/bin/cp
  '';

  preBuild = ''
    export SGX_SDK=${intelSGXPackages.sdk}/opt/intel/sgxsdk
  '';
}
