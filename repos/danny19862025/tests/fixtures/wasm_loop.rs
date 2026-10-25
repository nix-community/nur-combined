#![no_std]
#[link(wasm_import_module = "spotlight")]
unsafe extern "C" { fn emit(ptr: *const u8, len: i32); }
#[panic_handler]
fn panic(_: &core::panic::PanicInfo<'_>) -> ! { loop {} }
#[unsafe(no_mangle)]
pub extern "C" fn spotlight_run() {
    let message = br#"{"type":"result","id":"first","title":"WASM before loop"}"#;
    unsafe { emit(message.as_ptr(), message.len() as i32); }
    loop { core::hint::black_box(1); }
}
