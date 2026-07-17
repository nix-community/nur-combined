fn main() {
    let mut parser = vt100::Parser::new(24, 80, 0);
    for row in parser.screen().rows() {
        // print types
        for cell in row.cells() {
            let c: char = cell.contents().chars().next().unwrap_or(' ');
            let fg = cell.fgcolor();
        }
    }
}
