{ stdenvNoCC
, lib
, fetchurl
, unzip
, ...
}:

stdenvNoCC.mkDerivation {
  pname = "ida-free";
  version = "82";
  src = fetchurl ({
    url = "https://out7.hex-rays.com/files/idafree82_linux.run";
    sha256 = "";
  });


  installPhase = ''
  '';
  meta = {
    description = ''
      free version of IDA offers a privilege opportunity to see IDA in action.
      This light but powerful tool can quickly analyze the binary code samples
      and users can save and look closer at the analysis results. 
    '';
    homepage = "https://open.oppomobile.com/bbs/forum.php?mod=viewthread&tid=2274";
    #    maintainers = with maintainers; [ oluceps ];
  };
}
