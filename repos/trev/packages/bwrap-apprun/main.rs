use std::env;
use std::fs;
use std::os::unix::process::CommandExt;
use std::process::Command;

fn main() {
    let exe = env::current_exe().unwrap();
    let location = exe.parent().unwrap();

    // --bind /$name /$name for everything in the root except dev and proc
    let mut args: Vec<String> = fs::read_dir("/")
        .unwrap()
        .filter_map(|e| e.ok())
        .map(|e| e.file_name().into_string().unwrap())
        .filter(|name| name != "dev" && name != "proc")
        .flat_map(|name| {
            let path = format!("/{name}");
            ["--bind".to_string(), path.clone(), path]
        })
        .collect();

    // --dev-bind /dev /dev --proc /proc
    args.extend_from_slice(&[
        "--dev-bind".to_string(),
        "/dev".to_string(),
        "/dev".to_string(),
        "--proc".to_string(),
        "/proc".to_string(),
    ]);

    // --ro-bind $location/nix /nix
    args.extend_from_slice(&[
        "--ro-bind".to_string(),
        location.join("nix").to_string_lossy().into_owned(),
        "/nix".to_string(),
    ]);

    // entrypoint
    let entrypoint = fs::read_link(location.join("entrypoint")).unwrap();
    args.push(entrypoint.to_string_lossy().into_owned());

    // $@
    args.extend(env::args().skip(1));

    let err = Command::new(location.join("bwrap")).args(&args).exec();
    eprintln!("Failed to exec bwrap: {err}");
    std::process::exit(1);
}
