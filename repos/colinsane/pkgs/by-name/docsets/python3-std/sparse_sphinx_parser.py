from doc2dash.parsers.intersphinx import InterSphinxParser
from doc2dash.parsers.types import EntryType

class InterSphinxParserLessNoise(InterSphinxParser):
    def convert_type(self, inv_type: str) -> EntryType | None:
        # Sphinx is too noisy: we don't want page labels etc to drown out the actual API references
        if inv_type.split(":")[-1] in [ "cmdoption", "doc", "envvar", "label", "macro", "opcode", "option", "term" ]:
            return

        return super().convert_type(inv_type)
