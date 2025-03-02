{ gnuradio, boost181, ... }@args:

# Recent updates upgraded boost to a version which deprecated a lot of things causing a lot of breakage
# Since boost versions have to match, override it to the last known working version
gnuradio.override ({
  unwrapped = gnuradio.unwrapped.override { 
    boost = boost181;
  };
} // (removeAttrs args ["boost181" "gnuradio"] ))  