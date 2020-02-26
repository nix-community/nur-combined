from afew.filters.BaseFilter import Filter
from afew.FilterRegistry import register_filter
from re import findall


PATTERN = r'\[(\w+)\]'


@register_filter
class LobstersFilter(Filter):
    message = 'Lobste.rs stories and comments'
    query = 'from:lobste.rs AND NOT tag:lobste.rs'

    def handle_message(self, message):
        # get tags from subject line
        subject = message.get_header('Subject')
        matches = findall(PATTERN, subject)
        tags = [ ('lobste.rs/' + x) for x in findall(PATTERN, subject) ]

        self.add_tags(message, 'lobste.rs', *tags)
        self.remove_tags(message, 'removing lobste.rs from new', 'new')
