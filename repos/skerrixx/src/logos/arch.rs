use super::Logo;

pub const LOGO: Logo = Logo {
    id: "arch",
    aliases: &["archlinux"],
    display_name: "󰣇 arch",
    art: r#"
          /\
         /  \ 
        /    \ 
       _\     \ 
      /        \ 
     /          \ 
    /     __   \_\  
   /     /  \     \
  /__,--'    '--,__\
"#,
    color: (106, 230, 255),
};
