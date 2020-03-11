{ stdenv, fetchgit, ... }:

stdenv.mkDerivation rec {
  version = "2019-09-30";
  name = "lv2vst-${version}";

  src = fetchgit {
    url = "https://github.com/x42/lv2vst.git";
    rev = "3fc413550dbe7b37a60ad7808dde05c4670c7bb4";
    sha256 = "0dq1r95fxqwirkyv91j4qbigrazh0wsy769kc27yysl69p3lpgq3";
  };

  installPhase = "PREFIX=$out VSTDIR=$out/lib/vst/ make install";

  buildInputs = [ ];

  meta = with stdenv.lib; {
    description = "experimental LV2 to VST2.x wrapper";
    homepage = "https://github.com/x42/lv2vst";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mrVanDalo ];
  };
}
