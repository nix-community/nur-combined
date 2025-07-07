project('beat-detector', 'cpp', default_options : ['cpp_std=c++17'])

deps = [dependency('libpipewire-0.3'), dependency('aubio'), dependency('threads'), dependency('libspa-0.2')]

executable('beat-detector', 'main.cpp', dependencies : deps, install : true)