# Tasks.org desktop packaging notes

## `jpackage` output

The Gradle task used by this package,
`:composeApp:createDistributable`, uses Compose Desktop and OpenJDK's
`jpackage` tooling to create an application image. The relevant generated
layout is:

```text
tasks-org/
├── bin/tasks-org
└── lib/
    ├── app/
    │   ├── tasks-org.cfg
    │   ├── *.jar
    │   └── resources and native libraries
    ├── runtime/
    │   └── jlink-generated Java runtime
    └── libapplauncher.so
```

`bin/tasks-org` is a native `jpackage` launcher. It reads
`lib/app/tasks-org.cfg`, prepares the classpath and native library search
path, and loads the bundled runtime. The configuration file is generated
during the build and is not present in the upstream source tree.

For version 15.12, its non-classpath settings are:

```ini
[Application]
app.mainclass=MainKt

[JavaOptions]
java-options=-Djpackage.app-version=15.12.0
java-options=-Dcompose.application.resources.dir=$APPDIR/resources
java-options=-Dcompose.application.configure.swing.globals=true
java-options=-Dskiko.library.path=$APPDIR
```

It also contains one `app.classpath=$APPDIR/<jar>` entry for every
application and dependency JAR (208 entries for version 15.12).

## Harmless launcher coredump

On NixOS, launching the generated application produces a coredump from a
helper process even though Tasks.org starts and operates normally. The core
has only one thread and ends with this native stack:

```text
__pthread_kill_implementation
raise
abort
__gnu_cxx::__verbose_terminate_handler
std::terminate
__cxa_pure_virtual
Logger::log
dcon at LinuxLauncherLib.cpp:161
_dl_call_fini
_dl_fini
```

The failure is in OpenJDK's `libapplauncher`, not in Tasks.org, Kotlin, or
Compose. `LinuxLauncherLib.cpp` defines a shared-library destructor which
calls:

```cpp
LOG_TRACE("unload");
```

During teardown, the default logger still points at a C++ `LogAppender`
whose derived object has already been destroyed. Dispatching `append()`
therefore reaches `__cxa_pure_virtual`, which calls `std::terminate()` and
raises `SIGABRT`.

Relevant OpenJDK sources:

- `src/jdk.jpackage/linux/native/libapplauncher/LinuxLauncherLib.cpp`
- `src/jdk.jpackage/share/native/common/Log.cpp`
- `src/jdk.jpackage/share/native/common/app.cpp`

This was independently reproduced with a one-class Java program packaged
by the same Nix `jdk21`:

```text
pure virtual method called
terminate called without an active exception
hello
exit-status=0
```

An `strace -ff` of that reproducer showed the native launcher creating a
helper/relaunch process. The helper died with `SIGABRT`; the parent observed
`CLD_DUMPED` but continued into the JVM, printed `hello`, and exited with
status 0. This explains why systemd-coredump reports a crash while the real
application continues to work.

The Android SDK configuration is unrelated to this failure.

## Shared Android and desktop build

The upstream Gradle project is built once by `androidPackages/tasks`. That
build runs both `:app:assembleGenericRelease` and
`:composeApp:createDistributable`, then exposes the generated desktop
application under its `desktop/` output directory. This package only extracts
that application image and adds the Linux wrapper, icon, and desktop entry.

## Manual launcher

The package replaces `bin/tasks-org` with `launcher.bash`. The script parses
the generated `tasks-org.cfg` at startup, expands `$APPDIR`, assembles the
generated classpath, preserves every generated JVM option, and invokes Nix's
`jdk21` with the configured main class. Command-line arguments are forwarded
unchanged.

This bypasses `libapplauncher.so`, eliminating its teardown coredump while
also replacing the launcher-only `jlink` runtime, which does not include a
`bin/java` executable. The unused runtime and `libapplauncher.so` are removed
from the desktop package.

Because the parser consumes the generated configuration rather than a copied
classpath, dependency changes do not require corresponding launcher updates.
