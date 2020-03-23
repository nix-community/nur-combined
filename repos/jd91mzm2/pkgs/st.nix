{ st, fetchurl, writeText }:

st.override {
  patches = [
    (fetchurl { url = "https://st.suckless.org/patches/xresources/st-xresources-20190105-3be4cf1.diff"; hash = "sha256:112zi7jqzj6601gp54nr4b7si99g29lz61c44rgcpgpfddwmpibi"; })
    (writeText "change-background" ''
      diff --git a/config.def.h b/config.def.h
      index 0e01717..c494d3f 100644
      --- a/config.def.h
      +++ b/config.def.h
      @@ -116,9 +116,9 @@ static const char *colorname[] = {
        * Default colors (colorname index)
        * foreground, background, cursor, reverse cursor
        */
      -unsigned int defaultfg = 7;
      -unsigned int defaultbg = 0;
      -static unsigned int defaultcs = 256;
      +unsigned int defaultfg = 257;
      +unsigned int defaultbg = 256;
      +static unsigned int defaultcs = 257;
       static unsigned int defaultrcs = 257;
       
       /*
    '')
  ];
}
