use std::fmt;

/// for internal use.
/// parses only if the parser has no more bytes to yield.
struct Eof;

/// literal byte (character).
pub struct Lit<const BYTE: u8>;

/// parses without consuming any bytes from the parser.
/// used to construct strictly optional constructs.
pub struct Nul;

/// the two-item sequence of A followed by B.
pub struct Then<A, B>(pub A, pub B);

/// if A parses, then A, else parse B.
pub enum Either<A, B> {
    A(A),
    B(B),
}

/// parse A if possible, but don't error if it isn't present.
pub type Maybe<A> = Either<A, Nul>;

/// exists because Rust doesn't allow recursive type *aliases*.
pub struct OneOrMore<A>(Then<
    A,
    Maybe<Box<OneOrMore<A>>>
>);

// case-sensitive u8 character.
#[macro_export]
macro_rules! lit {
    ($BYTE:literal) => {
        Lit<{ $BYTE as u8 }>
    }
}

// case-insensitive u8 character.
#[macro_export]
macro_rules! ilit {
    ($BYTE:literal) => {
        Either<Lit<{ ($BYTE as u8).to_ascii_lowercase() }>, Lit<{ ($BYTE as u8).to_ascii_uppercase() }>>
    }
}


pub type PResult<P, C> = std::result::Result<(C, P), P>;
pub trait Parser: Sized {
    fn expect_byte(self, b: Option<u8>) -> PResult<Self, ()>;
    fn expect<C: Parse>(self) -> PResult<Self, C>;
    // {
    //     // support backtracking; i.e. don't modify `self` on failed parse
    //     match C::consume(self.clone()) {
    //          Ok(res) => res,
    //          Err(_) => self,
    //     }
    // }
    fn parse_all<C: Parse>(self) -> Result<C, ()> {
        match self.expect::<Then<C, Eof>>() {
            Ok((Then(c, _eof), _p)) => Ok(c),
            Err(_p) => Err(()),
        }
    }
}

impl<'a> Parser for &'a [u8] {
    fn expect_byte(self, b: Option<u8>) -> PResult<Self, ()> {
        match (b, self.split_first()) {
            // expected the correct character
            (Some(exp), Some((first, rest))) if *first == exp => Ok( ((), rest) ),
            // expected EOF, got EOF
            (None, None) => Ok( ((), self)),
            _ => Err(self),
        }
    }
    fn expect<C: Parse>(self) -> PResult<Self, C> {
        match C::consume(self.clone()) {
            Ok(res) => Ok(res),
            // rewind the parser should we fail
            Err(_p) => Err(self),
        }
    }
}

pub trait Parse: Sized {
    fn consume<P: Parser>(p: P) -> PResult<P, Self>;
}

impl Parse for Eof {
    fn consume<P: Parser>(p: P) -> PResult<P, Self> {
        let (_, p) = p.expect_byte(None)?;
        Ok((Self, p))
    }
}

impl Parse for Nul {
    fn consume<P: Parser>(p: P) -> PResult<P, Self> {
        Ok((Self, p))
    }
}

impl fmt::Display for Nul {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "")
    }
}

impl<const BYTE: u8> Parse for Lit<BYTE> {
    fn consume<P: Parser>(p: P) -> PResult<P, Self> {
        let (_, p) = p.expect_byte(Some(BYTE))?;
        Ok((Self, p))
    }
}

impl<const BYTE: u8> fmt::Display for Lit<BYTE> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", BYTE as char)
    }
}

impl<A: Parse, B: Parse> Parse for Then<A, B> {
    fn consume<P: Parser>(p: P) -> PResult<P, Self> {
        let (a, p) = p.expect()?;
        let (b, p) = p.expect()?;
        Ok((Self(a, b), p))
    }
}

impl<A: fmt::Display, B: fmt::Display> fmt::Display for Then<A, B> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}{}", self.0, self.1)
    }
}

impl<A: Parse, B: Parse> Parse for Either<A, B> {
    fn consume<P: Parser>(p: P) -> PResult<P, Self> {
        let p = match p.expect() {
            Ok((a, p)) => { return Ok((Self::A(a), p)); },
            Err(p) => p,
        };
        let p = match p.expect() {
            Ok((b, p)) => { return Ok((Self::B(b), p)); },
            Err(p) => p,
        };
        Err(p)
    }
}

impl<A: fmt::Display, B: fmt::Display> fmt::Display for Either<A, B> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::A(a) => write!(f, "{}", a),
            Self::B(b) => write!(f, "{}", b),
        }
    }
}

impl<T: Parse> Parse for Box<T> {
    fn consume<P: Parser>(p: P) -> PResult<P, Self> {
        match T::consume(p) {
            Ok((t, p)) => Ok((Box::new(t), p)),
            Err(p) => Err(p),
        }
    }
}

impl<T: Parse> Parse for OneOrMore<T> {
    fn consume<P: Parser>(p: P) -> PResult<P, Self> {
        match p.expect() {
            Ok((t, p)) => Ok((Self(t), p)),
            Err(p) => Err(p),
        }
    }
}

impl<T: fmt::Display> fmt::Display for OneOrMore<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

