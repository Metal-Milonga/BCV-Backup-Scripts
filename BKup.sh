#!/usr/bin/ksh

BCVDIR="/usr/local/bin/bcvscripts"
BKUPDIR="${BCVDIR}/Backup"
TARFILE="${BKUPDIR}/BCV-App-$(date "+%d%b%y-%H:%M:%S").tar"

tar cvf ${TARFILE} ${BCVDIR}/bin ${BCVDIR}/lib ${BCVDIR}/etc ${BCVDIR}/testing

gzip ${TARFILE}
