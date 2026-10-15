cfg_if::cfg_if! {
    if #[cfg(unix)] {
        const fn greeting() -> &'static str { "hello from unix" }
    } else {
        const fn greeting() -> &'static str { "hello from elsewhere" }
    }
}

fn main() {
    // keeps a panic location from a dependency in the binary, an argument panics
    let mut greetings: smallvec::SmallVec<[&str; 1]> = smallvec::smallvec![greeting()];
    println!("{}", greetings.remove(std::env::args().count() - 1));
}

#[cfg(test)]
mod tests {
    #[test]
    fn greeting() {
        assert!(super::greeting().starts_with("hello"));
    }
}
