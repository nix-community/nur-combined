{ st, fetchurl, writeText }:

st.override {
  patches = [
    (fetchurl { url = "https://st.suckless.org/patches/dracula/st-dracula-0.8.2.diff"; hash = "sha256:0zpvhjg8bzagwn19ggcdwirhwc17j23y5avcn71p74ysbwvy1f2y"; })
    (writeText "patch" ''
      diff --git a/config.def.h b/config.def.h
      index 0e01717..44c09b2 100644
      --- a/config.def.h
      +++ b/config.def.h
      @@ -5,7 +5,7 @@
        *
        * font: see http://freedesktop.org/software/fontconfig/fontconfig-user.html
        */
      -static char *font = "Liberation Mono:pixelsize=12:antialias=true:autohint=true";
      +static char *font = "Hack:pixelsize=13:antialias=true:autohint=true";
       static int borderpx = 2;
       
       /*
    '')
  ];
}
