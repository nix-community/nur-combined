'esversion: 6';

// console.log(Script.runtime);

// with this, we can join the chat without segfault
// and get the faulty access-violation context.
Process.setExceptionHandler(function (details) {

  // stop on undocumented or non-recoverable interruptions
  var bcontinue = Boolean(false);

  try {

    // Interceptor.attach(details.address, {
    //   onEnter: function(args) {
    //     console.log('called from:\n' +
    //     Thread.backtrace(this.context, Backtracer.ACCURATE)
    //     .map(DebugSymbol.fromAddress).join('\n') + '\n');
    //       }
    // });

    // details.address is a NativePointer
    switch (details.address.toInt32()) {

      case 0x572a58:
        // occurs after kai engine started.
        // cmp qword [rbx + 0x40], 0
        // console.log('Known access-violation 0x572a58');
        // if (! Memory.protect(details.memory.address, 64, 'r--'))
        //   console.log("Unable to fix memory at : " + details.memory.address);
        // else console.log("Fixed memory at : " + details.memory.address);
        bcontinue = true;
        // console.log(JSON.stringify(Process.findModuleByAddress(details.address)));
        // console.log(details.address.sub(moduleBase));
        break;
      case 0x573667:
        // Occurs when access to an arena with active server.
        // this make the webserver trashed ? so we exit.
        console.log('Known access-violation 0x573667');
        break;
      case 0x651030:
      case 0x651130:
        bcontinue = true;
        console.log('Known access-violation' + details.address );
        break;
      default:
        console.log(JSON.stringify(details));
        // console.log(details.address.sub(moduleBase));
    }
    Thread.sleep(1);

  } catch (e) { console.error(e); } // send (2);
  return bcontinue;
});
