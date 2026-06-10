{ gemini-desktop }:

gemini-desktop.overrideAttrs (old: {
  pname = "${old.pname}_zh";

  patches = (old.patches or [ ]) ++ [
    ./zh-CN.patch
  ];
})
