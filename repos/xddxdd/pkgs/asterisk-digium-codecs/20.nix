{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, asterisk
, curl
, ...
} @ args:

{
  opus = stdenv.mkDerivation rec {
    pname = "asterisk-codec-opus";
    version = "1.3.0";
    src = fetchurl {
      url = "https://downloads.digium.com/pub/telephony/codec_opus/asterisk-20.0/x86-64/codec_opus-20.0_${version}-x86_64.tar.gz";
      sha256 = "sha256-Fzrr7HV+7d0z3ydBSvrT4k9wH3ZuRP3K7u6TknrADaY=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ curl ];
    installPhase = ''
      mkdir -p $out
      cp * $out/
    '';

    meta = with lib; {
      description = "Asterisk Opus Codec by Digium";
      homepage = "https://downloads.digium.com/pub/telephony/codec_opus/";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

  silk = stdenv.mkDerivation rec {
    pname = "asterisk-codec-silk";
    version = "1.0.3";
    src = fetchurl {
      url = "https://downloads.digium.com/pub/telephony/codec_silk/asterisk-20.0/x86-64/codec_silk-20.0_${version}-x86_64.tar.gz";
      sha256 = "sha256-3wfAZtAo9XDhVtd7kQFNUdrVctC0NPhKX3LOhg2r51g=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];
    installPhase = ''
      mkdir -p $out
      cp * $out/
    '';

    meta = with lib; {
      description = "Asterisk Silk Codec by Digium";
      homepage = "https://downloads.digium.com/pub/telephony/codec_silk/";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

  siren7 = stdenv.mkDerivation rec {
    pname = "asterisk-codec-siren7";
    version = "1.0.7";
    src = fetchurl {
      url = "https://downloads.digium.com/pub/telephony/codec_siren7/asterisk-20.0/x86-64/codec_siren7-20.0_${version}-x86_64.tar.gz";
      sha256 = "sha256-4FeKTm+7XmTSL5w2lWRggq34J/fCKuhuSM3SbHLUGMU=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];
    installPhase = ''
      mkdir -p $out
      cp * $out/
    '';

    meta = with lib; {
      description = "Asterisk Siren7 Codec by Digium";
      homepage = "https://downloads.digium.com/pub/telephony/codec_siren7/";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

  siren14 = stdenv.mkDerivation rec {
    pname = "asterisk-codec-siren14";
    version = "1.0.7";
    src = fetchurl {
      url = "https://downloads.digium.com/pub/telephony/codec_siren14/asterisk-20.0/x86-64/codec_siren14-20.0_${version}-x86_64.tar.gz";
      sha256 = "sha256-ogQO8PNTKRNyflp4MogsNVnEVim1+XT5DhutBALPnwA=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];
    installPhase = ''
      mkdir -p $out
      cp * $out/
    '';

    meta = with lib; {
      description = "Asterisk Siren14 Codec by Digium";
      homepage = "https://downloads.digium.com/pub/telephony/codec_siren14/";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
}
