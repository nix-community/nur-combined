export PRISMA_SCHEMA_ENGINE_BINARY="@out@/bin/schema-engine"
export PRISMA_QUERY_ENGINE_BINARY="@out@/bin/query-engine"
export PRISMA_QUERY_ENGINE_LIBRARY="@out@/lib/libquery_engine.node"
export PRISMA_FMT_BINARY="@out@/bin/prisma-fmt"
# Tell prisma-client-py and prisma CLI to use the system engines instead
# of downloading them from binaries.prisma.sh on first invocation.
export PRISMA_VERSION="5.17.0"
export PRISMA_EXPECTED_ENGINE_VERSION="393aa359c9ad4a4bb28630fb5613f9c281cde053"
