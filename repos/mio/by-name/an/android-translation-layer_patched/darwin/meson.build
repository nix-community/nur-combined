sdl_audio = dependency('sdl2')
audio_test = executable('darwin-audio-test', ['audio.c', 'tests/audio.c'], dependencies: sdl_audio)
test('darwin-audio', audio_test, env: ['SDL_AUDIODRIVER=dummy'], timeout: 15)

host_test = executable('darwin-host-test', 'tests/host.m',
  dependencies: [libart_dep, libdl_bio_dep, libc_bio_dep, dependency('gtk4'), dependency('appleframeworks', modules: ['AppKit', 'WebKit'])],
  link_with: libtranslationlayer_so,
  # The ATL dylib resolves main-executable globals lazily; export the stubs.
  link_args: ['-Wl,-export_dynamic', '-Wl,-undefined,dynamic_lookup'],
  install_rpath: libart_dep.get_variable(pkgconfig: 'libdir') / 'art' + ':' + libart_dep.get_variable(pkgconfig: 'libdir'),
  install: true, install_dir: get_option('libexecdir') / 'atl-tests')
