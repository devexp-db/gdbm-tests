#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <gdbm/ndbm.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>



int main()
{
	DBM *testdb;
	datum	key;
	datum	data;
	datum	result;	
	char *a="test123";
	

	if( (testdb = (DBM *)dbm_open("test.db", O_CREAT|O_RDWR, S_IRWXU|S_IRWXG| S_IRWXO)) == NULL ){
		perror("dbm_open");
		exit(1);
	}
	
	key.dptr = a;
	key.dsize = strlen(a);
	data.dptr = a;	
	data.dsize = strlen(a);
	
	if( dbm_store( testdb, key, data, DBM_INSERT) < 0) {
		perror("dbm_store");
		exit(1);
	}

	result = dbm_fetch( testdb, key);
	dbm_close(testdb);

	return 0;
}
