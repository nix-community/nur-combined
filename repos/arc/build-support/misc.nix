{ self, super, lib, ... }: let
  attrs = {
    purple-plugins-arc = { pidgin, pidgin-skypeweb, pidgin-otr, purple-discord, purple-hangouts, purple-facebook, telegram-purple, purple-matrix, purple-plugin-pack, purple-lurch }: [
      pidgin-skypeweb pidgin-otr purple-discord purple-hangouts purple-facebook telegram-purple purple-matrix purple-plugin-pack purple-lurch
    ];
  };
in attrs
