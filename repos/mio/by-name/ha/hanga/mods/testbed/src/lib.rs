#[no_mangle]
pub extern "C" fn init_mod() -> i32 {
    // This is the WASM mod returning a status code to the engine!
    42
}
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
