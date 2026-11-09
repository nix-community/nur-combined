# stuntrally_patched

Patched `stuntrally` package from Nixpkgs.

## Build issue in upstream Nixpkgs

In nixos-unstable with GCC 16, `mygui` (the GUI library bundled/vendored for stuntrally in Nixpkgs) fails to compile because `std::allocator<void>::const_pointer` was removed in C++20:

```
MyGUI_Allocator.h:54:87: error: 'const_pointer' in 'class std::allocator<void>' does not name a type
   54 |                 template<typename U> struct rebind { typedef typename std::allocator<U>::const_pointer other; };
```

## Fix

Patch `MyGUIEngine/include/MyGUI_Allocator.h` to use `const void* = 0` when specializing `rebind` for `void`, and pass the patched `mygui` dependency to `stuntrally`.
