{ stdenv, fetchFromGitHub
, python3, python36Packages
, gstreamer
, gst-plugins-bad, gst-plugins-base, gst-plugins-good, gst-plugins-ugly
, rlwrap, fbset, ffmpeg, netcat
, gtk3, wrapGAppsHook
, gobjectIntrospection, gsettings_desktop_schemas
}:
python3.pkgs.buildPythonApplication rec {
  name = "voctomix-${version}";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "voc";
    repo = "voctomix";
    rev = version;
    sha256 = "1r3cfsm2ib90a29s6644f1crax910aq5fy790h3jwy6xb8fww3s4";
  };

  buildInputs = [
    wrapGAppsHook gobjectIntrospection
  ] ++ [ # Requirements
    gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly
  ] ++ [ # Optional for the Example-Scripts
    rlwrap fbset ffmpeg netcat
  ] ++ [ # GUI
    gstreamer
    gtk3
  ];

  propagatedBuildInputs = [
    python3 python36Packages.pygobject3
  ];

  preBuild = ''
    touch setup.py
  '';

  installPhase = ''
    mkdir -p $out/{bin,share}

    cp -r vocto{core,gui} $out/share
    ln -s $out/share/voctocore/voctocore.py $out/bin/voctocore
    ln -s $out/share/voctogui/voctogui.py $out/bin/voctogui
  '';

  meta = {
    description = "Full-HD Software Live-Video-Mixer in python";
    homepage = https://github.com/voc/voctomix;
    license = with stdenv.lib.licenses; [ mit ];
    maintainers = with stdenv.lib.maintainers; [ johnazoidberg ];
    platforms = stdenv.lib.platforms.linux;
  };
}
