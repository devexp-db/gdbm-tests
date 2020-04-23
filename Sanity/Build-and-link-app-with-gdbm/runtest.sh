#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/gdbm/Sanity/Build-and-link-app-with-gdbm
#   Description: Build and link app with gdbm
#   Author: Michal Nowak <mnowak@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 3 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.  See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see http://www.gnu.org/licenses/.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/lib/beakerlib/beakerlib.sh
. /usr/share/rhts-library/rhtslib.sh

PACKAGE="gdbm"

rlJournalStart
    rlPhaseStartSetup
        arch=$(uname -i)
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
	cp *.c *.h $TmpDir
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    rlPhaseStartTest scoredb
	# examples retrieved from http://www.cs.mun.ca/~rod/Fall97/cs3718/Examples/Gdbm/
	rlRun "gcc -lgdbm scoredb.c -o scoredb" 0 "Compile scoredb.c against gdbm"
        rlAssertExists "scoredb"
	rlRun "./scoredb" 0,139 "Run created program"
        rlAssertExists "records"
	./scoredb > records.log &&	rlAssertGrep "54 84 74" records.log
    rlPhaseEnd

    rlPhaseStartTest gtload
	# retrieved from gdbm sources
	rlRun "gcc -lgdbm gtload.c -o gtload" 0 "Compile gtload.c against gdbm"
        rlAssertExists "gtload"
	rlRun "./gtload -h" 0 "Run created program"
	./gtload -h &> gtload.log
	rlAssertGrep "blocksize" gtload.log
    rlPhaseEnd

    rlPhaseStartTest dtdump
	# retrieved from gdbm sources
	rlRun "gcc -lgdbm -lgdbm_compat dtdump.c -o dtdump" 0 "Compile dtdump.c against gdbm"
        rlAssertExists "dtdump"
	rlRun "./dtdump -h" 0 "Run created program"
	./dtdump -h &> dtdump.log
	rlAssertGrep "DBFILE" dtdump.log
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
