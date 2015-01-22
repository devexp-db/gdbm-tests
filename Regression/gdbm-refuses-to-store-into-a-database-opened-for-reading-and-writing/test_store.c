#include <gdbm.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ypdb_store gdbm_store
#define YPDB_REPLACE GDBM_REPLACE
#define ypdb_close gdbm_close
static GDBM_FILE dbm;

datum kdat, vdat;

static inline void
write_data (datum key, datum data)
{ 
  if (ypdb_store (dbm, key, data, YPDB_REPLACE) != 0)
    {
      perror ("error while storing file");
      ypdb_close (dbm);
      exit (1);
    }
}

int main(int argc, char **argv) 
{
  dbm = gdbm_open ("test.db", 0, GDBM_NEWDB | GDBM_FAST, 0600, NULL);
  kdat.dptr = "some key";
  kdat.dsize = strlen (kdat.dptr);
  vdat.dptr = "some value";
  vdat.dsize = strlen (vdat.dptr);
  write_data (kdat, vdat);
  ypdb_close (dbm);
  return 0;
}

