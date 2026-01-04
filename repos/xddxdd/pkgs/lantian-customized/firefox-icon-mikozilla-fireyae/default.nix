{
  lib,
  linkFarm,
  runCommand,
  imagemagick,
}:
let
  resizeIcon =
    size: src:
    runCommand "icon-${builtins.toString size}.png" { } ''
      ${lib.getExe imagemagick} ${src} \
        -resize ${builtins.toString size}x${builtins.toString size}! \
        $out
    '';
in
(linkFarm "firefox-icon-mikozilla-fireyae" (
  builtins.listToAttrs (
    lib.flatten (
      builtins.map
        (size: [
          # https://www.reddit.com/r/Genshin_Impact/comments/x73g4p/mikozilla_fireyae/
          {
            name = "share/icons/hicolor/${builtins.toString size}x${builtins.toString size}/apps/firefox.png";
            value =
              if size < 48 then
                resizeIcon size ./mikozilla-fireyae.png
              else
                resizeIcon size ./mikozilla-fireyae-petals.png;
          }
        ])
        [
          8
          10
          14
          16
          22
          24
          32
          36
          40
          48
          64
          72
          96
          128
          192
          256
          480
          512
        ]
    )
  )
))
// {
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Custom icon \"Mikozilla Fireyae\" for Firefox";
    homepage = "https://www.reddit.com/r/Genshin_Impact/comments/x73g4p/mikozilla_fireyae/";
    # Upstream did not specify license
    license = lib.licenses.unfreeRedistributable;
  };
}
