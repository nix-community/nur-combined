{
  fetchFromGitHub,
  lib,
  transmission_4,
}:
let
  transmissionWebControlSrc = fetchFromGitHub {
    owner = "ronggang";
    repo = "transmission-web-control";
    rev = "054e2edf7ee1ec859cec3ee5661a550481321a27";
    hash = "sha256-OsGT4emj6nLVNG87RZ/NW1RcSrw50phKGy04t45QvX8=";
  };
in
transmission_4.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    mv $out/share/transmission/public_html/index.html $out/share/transmission/public_html/index.original.html
    cp -r ${transmissionWebControlSrc}/src/* $out/share/transmission/public_html/
  '';

  patches = (old.patches or [ ]) ++ [ ./truncate-long-filename.patch ];

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
