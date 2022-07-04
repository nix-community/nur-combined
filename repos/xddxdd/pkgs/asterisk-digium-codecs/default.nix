{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, asterisk
, curl
, ...
} @ args:

assert lib.hasPrefix "19." asterisk.version;
{
  opus = stdenv.mkDerivation rec {
    pname = "asterisk-codec-opus";
    version = "1.3.0";
    src = fetchurl {
      url = "https://downloads.digium.com/pub/telephony/codec_opus/asterisk-19.0/x86-64/codec_opus-19.0_${version}-x86_64.tar.gz";
      sha256 = "sha256-Z2xNncDzrV2FhtUSmcdykRIkO27NDWqmhYe0LWCVBFU=";
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
      url = "https://downloads.digium.com/pub/telephony/codec_silk/asterisk-19.0/x86-64/codec_silk-19.0_${version}-x86_64.tar.gz";
      sha256 = "sha256-JO86snp+5vAJsJQeP0GDFaBXams2hwxmXue9tSAdzl4=";
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
      url = "https://downloads.digium.com/pub/telephony/codec_siren7/asterisk-19.0/x86-64/codec_siren7-19.0_${version}-x86_64.tar.gz";
      sha256 = "sha256-cQDOyN0SFMiC4TCSU1Eh4kBJh3VNevEk33P7Tsoc8eQ=";
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
      url = "https://downloads.digium.com/pub/telephony/codec_siren14/asterisk-19.0/x86-64/codec_siren14-19.0_${version}-x86_64.tar.gz";
      sha256 = "sha256-DApY+UQPfhkijrAAatSnu5NAar8ls06j+tu2KOLMb1w=";
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
