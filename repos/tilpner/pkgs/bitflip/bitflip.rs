use std::{ env, io };
use std::io::{ Read, BufReader, BufWriter };
use std::fs::File;

struct FlipReader<R: Read>(R);
impl<R: Read> Read for FlipReader<R> {
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
        let res = self.0.read(buf);
        for b in buf {
            *b = !*b;
        }
        res
    }
}

fn main() -> io::Result<()> {
    let input_path = env::var_os("input").expect("No $input variable");
    let output_path = env::var_os("out").expect("No $out variable");
    let mut input = FlipReader(BufReader::new(File::open(input_path)?));
    let mut output = BufWriter::new(File::create(output_path)?);

    io::copy(&mut input, &mut output)
        .map(|_| ())
}
