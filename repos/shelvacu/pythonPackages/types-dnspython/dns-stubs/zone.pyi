from collections.abc import MutableMapping, Iterable
from typing import Literal
import dns.name
import dns.node
import dns.transaction
import dns.rdataclass

class Zone(dns.transaction.TransactionManager):
    origin: dns.name.Name | None
    rdclass: dns.rdataclass.RdataClass
    nodes: MutableMapping[dns.name.Name, dns.node.Node]
    relativize: bool
