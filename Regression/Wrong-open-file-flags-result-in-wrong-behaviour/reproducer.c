/* Author: Robin Hack <rhack@redhat.com */

/* Based on quick ruby reproducer:
	1. Here's a quick test to demonstrate the problem:
	ruby -e 'require "gdbm"; gdbm = GDBM.open("x", nil); print gdbm'
  
	Actual results: prints a non-nil value and creates a file named "x"

	Expected results: prints "nil" and does *not* create any file
*/

#include <stdlib.h>
#include <stdio.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <gdbm.h>

int main(int argc, char **argv)
{
	GDBM_FILE db;
	
	db = gdbm_open("db.file", 512, GDBM_WRITER, 0666, NULL);

	if (db == NULL) {
		int fd = open("db.file", O_RDONLY);
		if (fd == -1) {
			return EXIT_SUCCESS;
		}
		close(fd);
	}

	return EXIT_FAILURE;
}
