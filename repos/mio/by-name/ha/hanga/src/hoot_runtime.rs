use wasmtime::*;
use crate::mod_manager::HostData;

pub fn add_to_linker(linker: &mut Linker<HostData>) -> Result<()> {
    linker.func_wrap("hangamod:kit", "kit-flag", |mut _caller: Caller<'_, HostData>, _arg: i32| -> i32 {
        // Core wasm implementation
        1
    })?;
    
    linker.func_wrap("hangamod:catalog", "catalog-parse", |mut _caller: Caller<'_, HostData>, _arg: i32| -> i32 {
        0
    })?;

    linker.func_wrap("hangamod:catalog", "catalog-name", |mut _caller: Caller<'_, HostData>, _arg1: i32, _arg2: i32| -> i32 {
        0
    })?;
    
    linker.func_wrap("hangamod:wire", "wire-bag-text", |mut _caller: Caller<'_, HostData>, _arg1: i32, _arg2: i32| -> i32 {
        0
    })?;

    linker.func_wrap("hangamod:wire", "wire-voxel-probe", |mut _caller: Caller<'_, HostData>, _arg1: i32, _arg2: i32| -> i32 {
        0
    })?;

    linker.func_wrap("hangamod:wire", "wire-fail", |mut _caller: Caller<'_, HostData>, _arg: i32| -> i32 {
        0
    })?;

    Ok(())
}
