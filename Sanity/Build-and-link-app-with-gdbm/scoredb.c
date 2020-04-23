#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gdbm.h>
#include "scoredb.h"

struct sr_tag {
    const char *name;
    int maxScores, numScores;
    int *scores;
};

Sr
srCreate( const char *studentName, int maxWIs ) {
    Sr sr;

    sr = (Sr)malloc( sizeof(*sr) );
    sr->name = strdup( studentName );
    sr->numScores = 0;
    sr->maxScores = maxWIs;
    sr->scores = (int *)malloc( sizeof(int) * maxWIs );

    return sr;
}

const char* srGetStudent( Sr sr ) {
    return sr->name;
}

int
srGetNoScores( Sr sr ) {
    return sr->numScores;
}

int
srGetMaxScores( Sr sr ) {
    return sr->maxScores;
}

int
srGetScore( Sr sr, int pos ) {
    return sr->scores[pos];
}

void
srSetScore( Sr sr, int score, int pos ) {
    sr->scores[pos] = score;
    if ( pos >= sr->numScores-1 ) {
	sr->numScores = pos+1;
    }
}

void
srFree( Sr sr ) {
    free( sr->scores );
    free( sr );
}

/* prefix: sdb ( score database ) */
struct sdb_tag  {
    const char *scoreDatabase;
    GDBM_FILE rd, wr;
};

Sdb
sdbCreate(const char *dbName) {
    Sdb db;

    db = (Sdb)malloc( sizeof(*db) );
    db->scoreDatabase = strdup( dbName );
    db->wr = gdbm_open( (char *)dbName, 1024, GDBM_WRCREAT, 0600, 0);
    gdbm_sync( db->wr );
    // one file handler for read/write is enough
    // db->rd = gdbm_open( (char *)dbName, 1024, GDBM_READER, 0600, 0);

    return db;
}

Sr
sdbGetStudentRecord( Sdb db, const char *name ) {
    Sr sr;
    datum key, content;
    int *rec, i;

    key.dptr = (char *)name;
    key.dsize = strlen( name ) + 1;
    content = gdbm_fetch( db->wr, key );
    if ( content.dptr == 0 ) return 0;
    rec = (int *)content.dptr;
    sr = srCreate( name, rec[0] );
    for( i = 0; i < rec[1]; i++ ) {
	srSetScore( sr, rec[i+2], i );
    }
    return sr;
}

void
sdbSetStudentRecord( Sdb db, const char *name, Sr sr ) {
    datum key, content;
    int *rec, i;

    rec = (int *)malloc( (2+srGetMaxScores( sr )) * sizeof(int) );
    rec[0] = srGetMaxScores(sr);
    rec[1] = srGetNoScores(sr);
    for( i = 0 ; i < srGetMaxScores(sr); i++ ) {
	rec[i+2] = srGetScore( sr, i );
    }
    content.dptr = (char *)rec;
    content.dsize = ( (2+srGetMaxScores( sr )) * sizeof(int) );
    key.dptr = (char *)name;
    key.dsize = strlen( name ) + 1;

    gdbm_store( db->wr, key, content, GDBM_REPLACE );
    free( rec );
}

void
sdbSync( Sdb db ) {
    gdbm_sync( db->wr );
}

void sdbFree( Sdb db ) {
    gdbm_close( db->wr );
    //gdbm_close( db->rd );
    free ( (void *)db->scoreDatabase);
    free( db );
}

/* test harness */
int
main() {
    Sdb db; 
    Sr sr;

    /* create the db */
    db = sdbCreate("records");
    sr = srCreate( "rod", 5 );
    srSetScore( sr, 54, 0 );
    srSetScore( sr, 84, 1);
    srSetScore( sr, 74, 2 );
    sdbSetStudentRecord( db, "rod", sr );
    srFree( sr );
    sdbSync( db );
    sdbFree( db );

    /* open the db */
    db = sdbCreate("records");
    sr = sdbGetStudentRecord( db, "rod" );
    printf("%d ", srGetScore( sr, 0 ) );
    printf("%d ", srGetScore( sr, 1 ) );
    printf("%d\n", srGetScore( sr, 2 ) );
    srFree( sr );
    sdbFree( db );

    return 0;
}
