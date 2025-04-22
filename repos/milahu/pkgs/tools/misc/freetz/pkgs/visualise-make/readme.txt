  /*
    #   Failed test at t/Makefile-GraphViz.t line 132.
    #          got: '1'
    #     expected: '0'
    # Looks like you failed 1 test of 38.
    t/Makefile-GraphViz.t .. Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/38 subtests 
  */

  # nix-generate-from-cpan Makefile::GraphViz



  /*
    t/makesimple.t ....... 1/84 
    #   Failed test 'TEST 1: basics - process returned the 0 status'
    #   at t/makesimple.t line 59.
    #          got: '2'
    #     expected: '0'

    #   Failed test 'TEST 1: basics - script/makesimple generated the right output'
    #   at t/makesimple.t line 68.
    #          got: ''
    #     expected: 'all:
    #       @echo hello world
    # '

    #   Failed test 'TEST 1: basics - script/makesimple generated the right error'
    #   at t/makesimple.t line 72.
    #          got: 'ERROR: line 181: No flavor found for the assignment at /build/Makefile-Parser-0.216/blib/lib/Makefile/Parser/GmakeDB.pm line 125.
    # '
    #     expected: ''
  */

  # nix-generate-from-cpan Makefile::Parser
