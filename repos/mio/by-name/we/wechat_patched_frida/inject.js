/**
 * Experimental Frida Script for WeChat Linux
 * Goal: Inject an "Automatic" option into the Appearance Settings.
 * 
 * Since Qt is statically linked in WeChat Linux, we cannot simply use Interceptor.attach
 * on Module.getExportByName(null, "QRadioButton::QRadioButton").
 * 
 * Instead, we must scan memory for the function signature that builds the UI,
 * or hook the internal theme setting function and try to override the UI state.
 */

console.log("[*] Injecting WeChat Frida Appearance Patch...");

// As a proof-of-concept, we would scan for the UI constructor signature here.
// Since we don't have the exact bytes, this is a mock implementation that searches
// for the "Automatic" string in memory and attempts to find cross-references.

const applySig = "53 48 81 ec 40 01 00 00 80 bf 80 00 00 00 00";

console.log("[*] Injecting WeChat Frida Appearance Patch...");

// 1. Hook the backend 'apply' function (using dynamic signature scanning)
Process.enumerateModules().forEach(function(m) {
    if (m.name === "wechat") {
        Memory.scan(m.base, m.size, applySig, {
            onMatch: function(address, size) {
                console.log("[+] Found appearance apply function at: " + address);
                Interceptor.attach(address, {
                    onEnter: function(args) {
                        const mode = args[1].toInt32();
                        console.log("[*] WeChat applying mode: " + mode);
                    }
                });
            },
            onComplete: function() {}
        });
    }
});

// 2. Dynamically find the UI layout array for the Radio Buttons
// Step A: Find the "Automatic" string in memory.
const hexAutomatic = "41 75 74 6f 6d 61 74 69 63 00"; // "Automatic\0"
Process.enumerateRanges('r--').forEach(function (range) {
    Memory.scan(range.base, range.size, hexAutomatic, {
        onMatch: function (address, size) {
            console.log("[+] Found 'Automatic' string at: " + address);
            
            // Step B: Search for absolute pointers to this string (xref scan).
            // WeChat is a 64-bit ELF, so we search for the 8-byte pointer to this address.
            const ptrBuf = ptr(address);
            const ptrHex = ptrBuf.toMatchPattern(); // e.g., "ef cd ab 89 67 45 23 01" (little-endian)
            
            Process.enumerateRanges('r--').forEach(function (dataRange) {
                Memory.scan(dataRange.base, dataRange.size, ptrHex, {
                    onMatch: function (ptrAddress, ptrSize) {
                        console.log("[+] Found pointer to 'Automatic' string at: " + ptrAddress);
                        console.log("[!] This memory region likely holds the UI layout definitions!");
                        
                        // Step C: If this is an array of size 2 (Light/Dark), 
                        // we would manipulate the array bounds here to size 3, 
                        // or hook the parser that reads this struct.
                        
                        // Example memory manipulation (conceptual):
                        // const arraySizePtr = ptrAddress.sub(0x10);
                        // if (arraySizePtr.readInt() === 2) {
                        //     Memory.protect(arraySizePtr, 4, 'rw-');
                        //     arraySizePtr.writeInt(3);
                        //     console.log("[*] Patched UI array size from 2 to 3!");
                        // }
                    },
                    onComplete: function() {}
                });
            });
        },
        onComplete: function () {}
    });
});

