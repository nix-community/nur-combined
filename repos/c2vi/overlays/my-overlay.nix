
final: prev: {
		#{
			#localPacketTracer8 = (pkgs.callPackage ../../prebuilt/packetTracer/default.nix {confDir = confDir;});
			#xdg-desktop-portal-termfilechooser = (pkgs.callPackage ../../mods/xdg-desktop-portal-termfilechooser/default.nix {});
			#firefox = inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin;
		#}
    #{
      #supabase-cli = pkgs.callPackage ./supabase.nix;
    #}

}


