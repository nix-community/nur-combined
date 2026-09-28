cfg_if::cfg_if! {
    if #[cfg(unix)] {
        fn greeting() -> &'static str { "hello from unix" }
    } else {
        fn greeting() -> &'static str { "hello from elsewhere" }
    }
}

fn main() {
    println!("{}", greeting());
}

#[cfg(test)]
mod tests {
    #[test]
    fn greeting() {
        assert!(super::greeting().starts_with("hello"));
    }
}
