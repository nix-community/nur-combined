with import ./nix {};
  mkShell { 
    buildInputs = [ 
      # cross platform tool for managing git hooks
      lefthook
      # need `npx` tool for invoking 'prettier tool for formatting markdown files
      nodejs-10_x
    ];
  }
