#!/bin/bash
 
# This script tries to check if the environment needed to upload
# data into tranSMART is present:

ERROR=0

if [ -z "$PGHOST" ]  || [ -z "$PGPORT" ]     || [ -z "$PGDATABASE" ] || \
   [ -z "$PGUSER" ]  || [ -z "$PGPASSWORD" ] || [ -z "$PGSQL_BIN" ]; then
	echo "Environment for Postgress not complete:"
	echo "    PGHOST=$PGHOST"
	echo "    PGPORT=$PGPORT"
	echo "    PGDATABASE=$PGDATABASE"
	echo "    PGUSER=$PGUSER"
	echo "    PGPASSWORD=$PGPASSWORD"
	echo "    PGSQL_BIN=$PGSQL_BIN"
	ERROR=1
fi

if [ -z "$KETTLE_JOBS_PSQL" ] || [ -z "$KETTLE_JOBS" ] || \
   [ -z "$KETTLE_HOME" ]      || [ -z "$KITCHEN" ] || [ -z "$R_JOBS_PSQL" ]; then
        echo "Environment for Kettle not complete:"
        echo "    KETTLE_JOBS_PSQL=$KETTLE_JOBS_PSQL"
        echo "    KETTLE_JOBS=$KETTLE_JOBS"
        echo "    KETTLE_HOME=$KETTLE_HOME"
        echo "    KITCHEN=$KITCHEN"
        echo "    R_JOBS_PSQL=$R_JOBS_PSQL"
	ERROR=1
fi

if [ ! -f "${KETTLE_HOME}/kettle.properties" ]; then
	echo "File: ${KETTLE_HOME}/kettle.properties  does not exists"
	echo "  You can try executing (if you have the proper rights):"
	echo "    make -C \${KETTLE_HOME}/.. kettle-home/kettle.properties"
	ERROR=1
else
	. "${KETTLE_HOME}/kettle.properties"
	if [ "${PGHOST}" != "${TM_CZ_DB_SERVER}" ] || \
	   [ "${PGPORT}" != "${TM_CZ_DB_PORT}" ]   || \
	   [ "${PGDATABASE}" != "${TM_CZ_DB_NAME}" ]; then
		echo "File: ${KETTLE_HOME}/kettle.properties  does not match your local environment"
		echo "  You can try executing (if you have the proper rights):"
		echo "    make -C \${KETTLE_HOME}/.. kettle-home/kettle.properties"
		ERROR=1
	fi
fi

PROGS=" Rscript					\
	load_annotation.sh			\
	load_acgh.sh 				\
	load_chromosomal_region_annotation.sh	\
	load_clinical.sh			\
	load_expression.sh			\
	load_mirna_annotation.sh		\
	load_mirna.sh				\
	load_proteomics_annotation.sh		\
	load_proteomics.sh			\
	load_ref_annotation.sh			\
	load_rnaseq.sh				\
	load_vcf.sh"

for prog in $PROGS; do
	type $prog >/dev/null 2>&1 || { echo >&2 "We may require $prog, bu we cannot find it."; ERROR=1; }
done

# Check if we have up-to-date-version of 'load_clinical_data.R;
count=$(grep -c '"", units_cd' "${R_JOBS_PSQL}/clinical/load_clinical_data.R")
if [ $count -gt 0 ]; then
	echo "You may have an old instance off ${R_JOBS_PSQL}/clinical/load_clinical_data.R"
	ERROR=1 
fi


if [ $ERROR  -eq 0 ]; then
	echo "Environment to upload data into tranSMART looks OK."
fi
