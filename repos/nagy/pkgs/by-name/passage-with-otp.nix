{
  pkgs,
  passage,
  ...
}:

let
  self = import ../.. { inherit pkgs; };
in
passage.overrideAttrs (old: {
  postInstall = ''
    ${old.postInstall}
    install -Dm755 -t $out/lib/passage/extensions \
      ${self.pass-otp-unstable}/lib/password-store/extensions/otp.bash
  '';
})
