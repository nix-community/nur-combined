{ mold, thunderbird-latest-unwrapped }:
thunderbird-latest-unwrapped.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ mold ];

  configureFlags = (old.configureFlags or [ ]) ++ [ "--enable-linker=mold" ];
})
