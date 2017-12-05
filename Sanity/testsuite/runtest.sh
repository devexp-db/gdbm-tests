#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/gdbm/Sanity/testsuite
#   Description: runs test suite from src package
#   Author: Vaclav Danek <vdanek@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2017 Red Hat, Inc.
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 2 of
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

# Include Beaker environment
. /usr/bin/rhts-environment.sh || exit 1
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="gdbm"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
        rlRun "cp config.*.ppc64le $TmpDir"
        rlRun "pushd $TmpDir"
        # fetch srpm
        if  rlIsRHEL ; then
            rlRun "rlFetchSrcForInstalled $PACKAGE || yumdownloader --enablerepo='*' --source $PACKAGE" \
                   0 "Fetching the source rpm"
        elif  rlIsFedora ; then
            rlRun "yumdownloader --source $PACKAGE"
        fi
        package=`rpm -q --qf "%{SOURCERPM}" $PACKAGE`
        installlog=`mktemp /tmp/install.log.XXXXXX`
        rlLog "Using $installlog as installation log"
        rlRun "rpm -ivh $TmpDir/$package &> $installlog"
        rlLog "RHEL6 settings"
        BUILDDIR="$HOME/rpmbuild/BUILD"
        SPECDIR="$HOME/rpmbuild/SPECS"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "cd /root/rpmbuild"
        rlRun "rpmbuild -bp $SPECDIR/$PACKAGE.spec"
        rlRun "cd $BUILDDIR"
        rlRun "cd gdbm-*"
        rlRun "cp $TmpDir/config.*.ppc64le build-aux/"
        bash
        rlRun "./configure --disable-static --enable-libgdbm-compat"
        rlRun "make check"
        rlRun "ls | grep -v tests | xargs rm -rf"
        rlRun "cd tests"
        rlRun "rm -f testsuite.log"
        rlRun "./testsuite"
        rlAssertGrep "All .* tests were successful." testsuite.log
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
        rlRun "rm -rf /root/rpmbuild"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
