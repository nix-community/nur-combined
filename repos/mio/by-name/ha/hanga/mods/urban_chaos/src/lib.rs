#[no_mangle]
pub extern "C" fn init_mod() -> i32 {
    // This is the Urban Chaos mod initializing!
    // Minecraft + Luanti + GTA + Teardown logic hooks here
    100
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
