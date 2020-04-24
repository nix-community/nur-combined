self: super: {
  weechat = super.weechat.override {
    configure = { availablePlugins, ... }: {
      plugins = with self; with availablePlugins; [
         (python.withPackages (ps: with ps; [websocket_client emoji]))
         perl
         ruby
        ];
    };
  };

}
