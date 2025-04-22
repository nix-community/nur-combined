[ 95%] Linking CXX shared library libunrar.so
[ 95%] Built target unrar
[ 97%] Building CXX object CMakeFiles/stream-unrar.dir/stream_unrar.cpp.o
/build/source/stream_unrar.cpp: In function 'void listFiles(const std::string&, bool, std::vector<std::__cxx11::basic_string<char> >&, bool&)':
/build/source/stream_unrar.cpp:520:30: warning: 'int readdir_r(DIR*, dirent*, dirent**)' is deprecated [8;;https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#index-Wdeprecated-declarations-Wdeprecated-declarations8;;]
  520 |         while (0 == readdir_r(directory, &entry, &next_entry) && next_entry != NULL)
      |                     ~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In file included from /build/source/stream_unrar.cpp:37:
/nix/store/s3pvsv4as7mc8i2nwnk2hnsyi2qdj4bq-glibc-2.39-31-dev/include/dirent.h:185:12: note: declared here
  185 | extern int readdir_r (DIR *__restrict __dirp,
      |            ^~~~~~~~~
[100%] Linking CXX executable stream-unrar
[100%] Built target stream-unrar
buildPhase completed in 12 minutes 7 seconds
Running phase: installPhase
install flags: -j2 SHELL=/nix/store/h3bhzvz9ipglcybbcvkxvm4vg9lwvqg4-bash-5.2p26/bin/bash install
make: *** No rule to make target 'install'.  Stop.



TODO move libunrar.so to separate drv

TODO fix warning: 'int readdir_r(DIR*, dirent*, dirent**)' is deprecated

TODO add install instructions to CMakeLists.txt
