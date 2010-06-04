#ifndef SCOREDB_H 
#define SCOREDB_H 

/*
 * Database that maintains a table of student names and their
 * associate scores in a sequence of work items.
 */

/* prefix: sr (score record) */
typedef struct sr_tag *Sr;

Sr srCreate( const char *studentName, int maxWIs );
const char* srGetStudent( Sr sr );
int srGetNoScores( Sr sr );
int srGetMaxScores( Sr sr );
int srGetScore( Sr sr, int pos );
void srSetScore( Sr sr, int score, int pos );
void srFree( Sr sr );


/* prefix: sdb ( score database ) */
typedef struct sdb_tag *Sdb;

Sdb sdbCreate(const char *dbName );
Sr sdbGetStudentRecord( Sdb db, const char *name );
void sdbSetStudentRecord( Sdb db, const char *name, Sr sr );
void sdbSync( Sdb db );
void sdbFree( Sdb db );

#endif
