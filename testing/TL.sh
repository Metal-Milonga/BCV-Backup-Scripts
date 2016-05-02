#!/usr/bin/ksh

typeset ROUNDS=${1}
typeset CLICKS=${2}
Total_Time=$(( ${ROUNDS} * ${CLICKS} ))
MINUTES=$(( ${Total_Time} / 60 ))
SECONDS=$(( ${Total_Time} % 60 ))

print "Waiting ${MINUTES} minute(s) ${SECONDS} second(s). ${ROUNDS} round(s) by ${CLICKS} click(s)."
cat << END_OF_TEXT
....5....10...15...20...25...30...35...40...45...50...55...60
    |    |    |    |    |    |    |    |    |    |    |    |
END_OF_TEXT

until [[ ${ROUNDS} -eq 0 ]]
do
	TICKS=${CLICKS}
	until [[ ${TICKS} -eq 0 ]]
	do
		print -n "."
		sleep 1
		TICKS=$((TICKS - 1))
	done
	print
	typeset ROUNDS=$((ROUNDS - 1))
done

