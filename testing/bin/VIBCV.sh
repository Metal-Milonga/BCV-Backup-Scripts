#!/usr/bin/ksh

BASEDIR=/usr/local/bin/bcvscripts/testing
LLIBDIR=/usr/local/bin/bcvscripts/testing/lib
LBINDIR=/usr/local/bin/bcvscripts/testing/bin
LETCDIR=/usr/local/bin/bcvscripts/testing/etc

Editing() {
cd $BASEDIR

print "What do you need to edit?"
ls $LBINDIR $LLIBDIR $LETCDIR

print
print "Enter the directory you need to edit from: \c"
read DIR

print
print "Enter choice: \c"
read ANSWER
#print You want to edit: $ANSWER

vi $BASEDIR/$DIR/$ANSWER
}
Editing

print "Edit another file? \c"
read EDIT_AGAIN

if [[ ${EDIT_AGAIN} = @([Yy])?([eE][sS]) ]]
then
	Editing
fi
