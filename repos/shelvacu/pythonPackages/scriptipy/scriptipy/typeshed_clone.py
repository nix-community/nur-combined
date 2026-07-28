# Utility types for typeshed
#
# See the README.md file in this directory for more information.

from __future__ import annotations
import sys
from collections.abc import (
    Awaitable,
    Callable,
    Iterable,
    Iterator,
    Sequence,
    Set as AbstractSet,
    Sized,
)
from dataclasses import Field
from os import PathLike
from types import FrameType, TracebackType
from typing import (
    Any,
    AnyStr,
    ClassVar,
    Final,
    Literal,
    Protocol,
    SupportsFloat,
    SupportsIndex,
    SupportsInt,
    final,
    overload,
)
from typing_extensions import Buffer, LiteralString, Self as _Self, TypeAlias

# For partially known annotations. Usually, fields where type annotations
# haven't been added are left unannotated, but in some situations this
# isn't possible or a type is already partially known. In cases like these,
# use Incomplete instead of Any as a marker. For example, use
# "Incomplete | None" instead of "Any | None".
Incomplete: TypeAlias = Any  # stable

# To describe a function parameter that is unused and will work with anything.
Unused: TypeAlias = object  # stable

# Marker for return types that include None, but where forcing the user to
# check for None can be detrimental. Sometimes called "the Any trick". See
# https://typing.python.org/en/latest/guides/writing_stubs.html#the-any-trick
# for more information.
MaybeNone: TypeAlias = Any  # stable

# Used to mark arguments that default to a sentinel value. This prevents
# stubtest from complaining about the default value not matching.
#
# def foo(x: int | None = sentinel) -> None: ...
#
# In cases where the sentinel object is exported and can be used by user code,
# a construct like this is better:
#
# _SentinelType = NewType("_SentinelType", object)  # does not exist at runtime
# sentinel: Final[_SentinelType]
# def foo(x: int | None | _SentinelType = ...) -> None: ...
sentinel: Any  # stable


# stable
class IdentityFunction(Protocol):
    def __call__[T](self, x: T, /) -> T: ...


# stable
class SupportsNext[T](Protocol):
    def __next__(self) -> T: ...


# stable
class SupportsAnext[T](Protocol):
    def __anext__(self) -> Awaitable[T]: ...


class SupportsBool(Protocol):
    def __bool__(self) -> bool: ...


# Comparison protocols
class SupportsDunderLT[T](Protocol):
    def __lt__(self, other: T, /) -> SupportsBool: ...


class SupportsDunderGT[T](Protocol):
    def __gt__(self, other: T, /) -> SupportsBool: ...


class SupportsDunderLE[T](Protocol):
    def __le__(self, other: T, /) -> SupportsBool: ...


class SupportsDunderGE[T](Protocol):
    def __ge__(self, other: T, /) -> SupportsBool: ...


class SupportsAllComparisons(
    SupportsDunderLT[Any],
    SupportsDunderGT[Any],
    SupportsDunderLE[Any],
    SupportsDunderGE[Any],
    Protocol,
): ...


SupportsRichComparison: TypeAlias = SupportsDunderLT[Any] | SupportsDunderGT[Any]

# Dunder protocols


class SupportsAdd[T, R](Protocol):
    def __add__(self, x: T, /) -> R: ...


class SupportsRAdd[T, R](Protocol):
    def __radd__(self, x: T, /) -> R: ...


class SupportsSub[T, R](Protocol):
    def __sub__(self, x: T, /) -> R: ...


class SupportsRSub[T, R](Protocol):
    def __rsub__(self, x: T, /) -> R: ...


class SupportsMul[T, R](Protocol):
    def __mul__(self, x: T, /) -> R: ...


class SupportsRMul[T, R](Protocol):
    def __rmul__(self, x: T, /) -> R: ...


class SupportsDivMod[T, R](Protocol):
    def __divmod__(self, other: T, /) -> R: ...


class SupportsRDivMod[T, R](Protocol):
    def __rdivmod__(self, other: T, /) -> R: ...


# This protocol is generic over the iterator type, while Iterable is
# generic over the type that is iterated over.
class SupportsIter[T](Protocol):
    def __iter__(self) -> T: ...


# This protocol is generic over the iterator type, while AsyncIterable is
# generic over the type that is iterated over.
class SupportsAiter[T](Protocol):
    def __aiter__(self) -> T: ...


class SupportsLen(Protocol):
    def __len__(self) -> int: ...


class SupportsLenAndGetItem[T](Protocol):
    def __len__(self) -> int: ...
    def __getitem__(self, k: int, /) -> T: ...


class SupportsTrunc(Protocol):
    def __trunc__(self) -> int: ...


# Mapping-like protocols


# stable
class SupportsItems[KT, VT](Protocol):
    def items(self) -> AbstractSet[tuple[KT, VT]]: ...


# stable
class SupportsKeysAndGetItem[KT, VT](Protocol):
    def keys(self) -> Iterable[KT]: ...
    def __getitem__(self, key: KT, /) -> VT: ...


# stable
class SupportsGetItem[KT, VT](Protocol):
    def __getitem__(self, key: KT, /) -> VT: ...


# stable
class SupportsContainsAndGetItem[KT, VT](Protocol):
    def __contains__(self, x: Any, /) -> bool: ...
    def __getitem__(self, key: KT, /) -> VT: ...


# stable
class SupportsItemAccess[KT, VT](Protocol):
    def __contains__(self, x: Any, /) -> bool: ...
    def __getitem__(self, key: KT, /) -> VT: ...
    def __setitem__(self, key: KT, value: VT, /) -> None: ...
    def __delitem__(self, key: KT, /) -> None: ...


StrPath: TypeAlias = str | PathLike[str]  # stable
BytesPath: TypeAlias = bytes | PathLike[bytes]  # stable
GenericPath: TypeAlias = AnyStr | PathLike[AnyStr]
StrOrBytesPath: TypeAlias = str | bytes | PathLike[str] | PathLike[bytes]  # stable

OpenTextModeUpdating: TypeAlias = Literal[
    "r+",
    "+r",
    "rt+",
    "r+t",
    "+rt",
    "tr+",
    "t+r",
    "+tr",
    "w+",
    "+w",
    "wt+",
    "w+t",
    "+wt",
    "tw+",
    "t+w",
    "+tw",
    "a+",
    "+a",
    "at+",
    "a+t",
    "+at",
    "ta+",
    "t+a",
    "+ta",
    "x+",
    "+x",
    "xt+",
    "x+t",
    "+xt",
    "tx+",
    "t+x",
    "+tx",
]
OpenTextModeWriting: TypeAlias = Literal[
    "w", "wt", "tw", "a", "at", "ta", "x", "xt", "tx"
]
OpenTextModeReading: TypeAlias = Literal[
    "r", "rt", "tr", "U", "rU", "Ur", "rtU", "rUt", "Urt", "trU", "tUr", "Utr"
]
OpenTextMode: TypeAlias = (
    OpenTextModeUpdating | OpenTextModeWriting | OpenTextModeReading
)
OpenBinaryModeUpdating: TypeAlias = Literal[
    "rb+",
    "r+b",
    "+rb",
    "br+",
    "b+r",
    "+br",
    "wb+",
    "w+b",
    "+wb",
    "bw+",
    "b+w",
    "+bw",
    "ab+",
    "a+b",
    "+ab",
    "ba+",
    "b+a",
    "+ba",
    "xb+",
    "x+b",
    "+xb",
    "bx+",
    "b+x",
    "+bx",
]
OpenBinaryModeWriting: TypeAlias = Literal["wb", "bw", "ab", "ba", "xb", "bx"]
OpenBinaryModeReading: TypeAlias = Literal[
    "rb", "br", "rbU", "rUb", "Urb", "brU", "bUr", "Ubr"
]
OpenBinaryMode: TypeAlias = (
    OpenBinaryModeUpdating | OpenBinaryModeReading | OpenBinaryModeWriting
)


# stable
class HasFileno(Protocol):
    def fileno(self) -> int: ...


FileDescriptor: TypeAlias = int  # stable
FileDescriptorLike: TypeAlias = int | HasFileno  # stable
FileDescriptorOrPath: TypeAlias = int | StrOrBytesPath


# stable
class SupportsRead[T](Protocol):
    def read(self, length: int = ..., /) -> T: ...


# stable
class SupportsReadline[T](Protocol):
    def readline(self, length: int = ..., /) -> T: ...


# stable
class SupportsNoArgReadline[T](Protocol):
    def readline(self) -> T: ...


# stable
class SupportsWrite[T](Protocol):
    def write(self, s: T, /) -> object: ...


# stable
class SupportsFlush(Protocol):
    def flush(self) -> object: ...


# Suitable for dictionary view objects
class Viewable[T](Protocol):
    def __len__(self) -> int: ...
    def __iter__(self) -> Iterator[T]: ...


class SupportsGetItemViewable[KT, VT](Protocol):
    def __len__(self) -> int: ...
    def __iter__(self) -> Iterator[KT]: ...
    def __getitem__(self, key: KT, /) -> VT: ...


# Unfortunately PEP 688 does not allow us to distinguish read-only
# from writable buffers. We use these aliases for readability for now.
# Perhaps a future extension of the buffer protocol will allow us to
# distinguish these cases in the type system.
ReadOnlyBuffer: TypeAlias = Buffer  # stable
# Anything that implements the read-write buffer interface.
WriteableBuffer: TypeAlias = Buffer
# Same as WriteableBuffer, but also includes read-only buffer types (like bytes).
ReadableBuffer: TypeAlias = Buffer  # stable


class SliceableBuffer(Buffer, Protocol):
    def __getitem__(self, slice: slice[SupportsIndex | None], /) -> Sequence[int]: ...


class IndexableBuffer(Buffer, Protocol):
    def __getitem__(self, i: int, /) -> int: ...


class SupportsGetItemBuffer(SliceableBuffer, IndexableBuffer, Protocol):
    def __contains__(self, x: Any, /) -> bool: ...
    @overload
    def __getitem__(self, slice: slice[SupportsIndex | None], /) -> Sequence[int]: ...
    @overload
    def __getitem__(self, i: int, /) -> int: ...


class SizedBuffer(Sized, Buffer, Protocol): ...


ExcInfo: TypeAlias = tuple[type[BaseException], BaseException, TracebackType]
OptExcInfo: TypeAlias = ExcInfo | tuple[None, None, None]

# stable
if sys.version_info >= (3, 10):
    from types import NoneType as NoneType
else:
    # Used by type checkers for checks involving None (does not exist at runtime)
    @final
    class NoneType:
        def __bool__(self) -> Literal[False]: ...


# Objects suitable to be passed to sys.setprofile, threading.setprofile, and similar
ProfileFunction: TypeAlias = Callable[[FrameType, str, Any], object]

# Objects suitable to be passed to sys.settrace, threading.settrace, and similar
type TraceFunction = Callable[[FrameType, str, Any], TraceFunction | None]


# experimental
# Might not work as expected for pyright, see
#   https://github.com/python/typeshed/pull/9362
#   https://github.com/microsoft/pyright/issues/4339
class DataclassInstance(Protocol):
    __dataclass_fields__: ClassVar[dict[str, Field[Any]]]


# Anything that can be passed to the int/float constructors
if sys.version_info >= (3, 14):
    ConvertibleToInt: TypeAlias = str | ReadableBuffer | SupportsInt | SupportsIndex
else:
    ConvertibleToInt: TypeAlias = (
        str | ReadableBuffer | SupportsInt | SupportsIndex | SupportsTrunc
    )
ConvertibleToFloat: TypeAlias = str | ReadableBuffer | SupportsFloat | SupportsIndex

# A few classes updated from Foo(str, Enum) to Foo(StrEnum). This is a convenience so these
# can be accurate on all python versions without getting too wordy
if sys.version_info >= (3, 11):
    from enum import StrEnum as StrEnum
else:
    from enum import Enum

    class StrEnum(str, Enum): ...


# Objects that appear in annotations or in type expressions.
# Similar to PEP 747's TypeForm but a little broader.
AnnotationForm: TypeAlias = Any

if sys.version_info >= (3, 14):
    from annotationlib import Format

    # These return annotations, which can be arbitrary objects
    AnnotateFunc: TypeAlias = Callable[[Format], dict[str, AnnotationForm]]
    EvaluateFunc: TypeAlias = Callable[[Format], AnnotationForm]
