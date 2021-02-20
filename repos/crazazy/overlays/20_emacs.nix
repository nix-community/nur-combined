# overlay for importing the emacs overlay et al
self: super: let
   inherit (super.lib.srcs) emacs-overlay emacs;
in
   { emacsBootstrap = { configDir ? /var/empty }: 
      import emacs { pkgs = self; inherit configDir; };
   } // (import emacs-overlay self super)
