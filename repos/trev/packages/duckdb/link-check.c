// Fails unless every extension named on the command line is loaded, to check programs linking
// passthru.link.static register its extensions.
#include <duckdb.h>
#include <stdio.h>

int main(int argc, char **argv) {
	duckdb_database database;
	duckdb_connection connection;
	if (duckdb_open(NULL, &database) != DuckDBSuccess || duckdb_connect(database, &connection) != DuckDBSuccess) {
		fprintf(stderr, "failed to open duckdb\n");
		return 1;
	}

	int status = 0;
	for (int i = 1; i < argc; i++) {
		char query[512];
		snprintf(query, sizeof(query),
		         "SELECT CASE WHEN count(*) = 0 THEN error('%s is not loaded') END "
		         "FROM duckdb_extensions() WHERE loaded AND extension_name = '%s'",
		         argv[i], argv[i]);
		duckdb_result result;
		if (duckdb_query(connection, query, &result) != DuckDBSuccess) {
			fprintf(stderr, "%s\n", duckdb_result_error(&result));
			status = 1;
		}
		duckdb_destroy_result(&result);
	}

	duckdb_disconnect(&connection);
	duckdb_close(&database);
	return status;
}
