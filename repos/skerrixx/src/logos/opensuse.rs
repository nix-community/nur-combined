use super::Logo;

const ART: &str = r#"
           .;ldkO0000Okdl;.
       .;d00xl:^''''''^:ok00d;.
     .d00l'                'o00d.
   .d0Kd'  Okxol:;,.          
  .OKKKK0kOKKKKKKKKKKOxo:,      
 ,0KKKKKKKKKKKKKKKK0P^,,,^dx:   
.OKKKKKKKKKKKKKKKKk'.oOPPb.'0k. 
:KKKKKKKKKKKKKKKKK: kKx..dd lKd  
dKKKKKKKKKKKOx0KKKd ^0KKKO' kKKc 
dKKKKKKKKKKKK;.;oOKx,..^..;kKKK0.
:KKKKKKKKKKKK0o;...^cdxxOK0O/^^'  .0K:
 kKKKKKKKKKKKKKKK0x;,,......,;od  lKk
 '0KKKKKKKKKKKKKKKKKKKKK00KKOo^  c00'
  'kKKKOxddxkOO00000Okxoc;''   .dKk'
    l0Ko.                    .c00l'
     'l0Kk:.              .;xK0l'
        'lkK0xl:;,,,,;:ldO0kl'
            '^:ldxkkkkxdl:^'
"#;

pub const TUMBLEWEED: Logo = Logo {
    id: "opensuse-tumbleweed",
    aliases: &["opensuse tumbleweed"],
    display_name: " tumbleweed",
    art: ART,
    color: (115, 186, 37),
};

pub const LEAP: Logo = Logo {
    id: "opensuse-leap",
    aliases: &["opensuse leap"],
    display_name: " leap",
    art: ART,
    color: (115, 186, 37),
};

pub const SLES: Logo = Logo {
    id: "sles",
    aliases: &[],
    display_name: " sles",
    art: ART,
    color: (0, 153, 204),
};
