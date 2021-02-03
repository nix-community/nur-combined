# overlay for importing the emacs overlay et al
self: super: let
   inherit (super.lib.srcs) emacs-overlay emacs;
in
   { emacsBootstrap = { configDir ? null }: 
      import emacs ({ pkgs = self; } // (if builtins.isNull configDir then { } else { inherit configDir; }));
   } // (import emacs-overlay self super)
