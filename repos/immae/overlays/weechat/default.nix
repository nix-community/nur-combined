self: super: {
  weechat = super.weechat.override {
    configure = { availablePlugins, ... }: {
      plugins = with self; with availablePlugins; [
          # Make sure websocket_client is not 0.55.0, it provokes
          # regular crashes
         (python.withPackages (ps: with ps; assert websocket_client.version == "0.54.0"; [websocket_client emoji]))
         perl
         ruby
        ];
    };
  };

}
