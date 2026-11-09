{
  rustdesk-flutter,
  libsodium,
}:

rustdesk-flutter.overrideAttrs (oldAttrs: {
  buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ libsodium ];
})
