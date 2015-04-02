#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/gdbm/Regression/disable-locking-by-NDBM_LOCK-variable
#   Description: setting NDBM_LOCK to 'no' will disable locking which is a performance bottleneck on NFS
#   Author: Ales Zelinka <azelinka@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2011 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/lib/beakerlib/beakerlib.sh

PACKAGE="gdbm"

rlJournalStart
rlPhaseStartSetup
    rlAssertRpm $PACKAGE
    if rlIsRHEL '<7'; then
	    rlRun "gcc -o dbm_test dbm_test.c -lgdbm" 0 "compiling the reproducer"
    else
	    rlRun "gcc -o dbm_test dbm_test.c -lgdbm_compat" 0 "compiling the reproducer"
    fi
rlPhaseEnd

rlPhaseStartTest
    NDBM_LOCK=yes strace ./dbm_test

    # Locking mechanism is different on newest rhels.
    LOCK_FUNCTION="flock"
    if rlIsRHEL '>=6'; then
	LOCK_FUNCTION="fcntl.*F_SETLK"
    fi

    rlRun "NDBM_LOCK=yes strace ./dbm_test 2>&1|grep ${LOCK_FUNCTION}" 0 "locking detected when running reproducer with locking allowed (NDBM_LOCK=yes)"
    NDBM_LOCK=no strace ./dbm_test
    rlRun "NDBM_LOCK=no strace ./dbm_test 2>&1|grep ${LOCK_FUNCTION}" 1 "locking _not_ detected when running reproducer with locking disabled (NDBM_LOCK=no)"
rlPhaseEnd

rlPhaseStartCleanup
    rlRun "rm -f dbm_test" 0 "removing compiled reproducer"
rlPhaseEnd
rlJournalPrintText
rlJournalEnd
