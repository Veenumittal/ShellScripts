#!/bin/bash

echo "ThIS SCRIPT IS ONLY FOR TRACES VALIDATION"
LOCAL_BASE_DIR="/cygdrive/c/Users/EMITVEE/TRACESVALIDATION"
LTNGDECODER="${LOCAL_BASE_DIR}/LTNG_TOOLS/ltng-283.4.5/ltng/bin"
OPERATOR_BASE_DIR=${LOCAL_BASE_DIR}/"TRACESVALIDATIONDIR"

TRACESINPUTDIR="${OPERATOR_BASE_DIR}/TRACESINPUTDIR"
LOGDIR="${OPERATOR_BASE_DIR}/logs"
EACHLOGDIR="${OPERATOR_BASE_DIR}/eachlogdir"
#Event file will be taken as input
EVENTFILE=$1
#Technology will be taken as input
TECH=$2
eventlist="${OPERATOR_BASE_DIR}/${EVENTFILE}"
output="${LOGDIR}/alloutput.txt"
failedoutput="${LOGDIR}/failedoutput.txt"
successoutput="${LOGDIR}/successoutput.txt"
tracesfilenames="${LOGDIR}/tracesfilenames.txt"
zipfiles="${LOGDIR}/zipfiles.txt"
gzfiles="${LOGDIR}/gzfiles.txt"
uniqmissingevents="${LOGDIR}/uniqmissingevents.txt"
tmp1="${LOGDIR}/tmp1.txt"
tmp2="${LOGDIR}/tmp2.txt"
uncommon="${LOGDIR}/uncommonevents.txt"
[ ! -d $LOGDIR ] && mkdir -p $LOGDIR
[ -f $failedoutput ] && rm $failedoutput
[ -f $output ] && rm $output
[ -f $successoutput ] && rm $successoutput
[ -f $tracesfilenames ] && rm $tracesfilenames
[ -f $zipfiles ] && rm $zipfiles
[ -f $uniqmissingevents ] && rm $uniqmissingevents
[ -f $tmp1 ] && rm $tmp1
[ -f $tmp1 ] && rm $tmp1
[ -f $uncommon ] && rm $uncommon
[ ! -d $TRACESINPUTDIR ]&& mkdir -p $TRACESINPUTDIR
[ -d $EACHLOGDIR ] && rm -rf $EACHLOGDIR
mkdir -p $EACHLOGDIR

if [[ $# -lt 2 ]]
then
        echo "Usage: ./Script name eventlist.txt 4g/3g/5g "
        exit -1
fi

UNZIP()
{
ls ${TRACESINPUTDIR} | grep "zip" > ${zipfiles}
if [ -s ${zipfiles} ]
then
        for filename in `cat ${zipfiles}`;
        do
                cd ${TRACESINPUTDIR}
                unzip -o ${filename}
                if [ $? -eq 0 ]
                then
                        echo "Successfully unzipped the file: ${filename}"
                else
                        echo "Unable to unzip the file: ${filename}. Please check manually"
                fi
        done
else
        echo "There are no zip files"
fi
}

GUNZIPFUN()
{
ls ${TRACESINPUTDIR} | grep "gz" > ${gzfiles}
if [ -s ${gzfiles} ]
then
        for filename in `cat ${gzfiles}`
        do
                cd ${TRACESINPUTDIR}
                /bin/gunzip ${filename}
                if [ $? -eq 0 ]
                then
                        echo "Successfully Gunzipped the file: ${filename}"
                else
                        echo "Unable to Gunzip the file: ${filename}. Please check manually"
                fi
        done
else
        echo "There are no gunzip files"
fi
}
TRACESREAD()
{
if [ $TECH == "3G" ]
then
        filetype="bin"
        keyword="event-id"
        echo "File extension is .${filetype}"
elif [ $TECH == "4G" ]
then
        filetype="bin"
        keyword="eventId"
        echo "File extension is .${filetype}"
elif [ $TECH == "5G" ]
then
        filetype="gpb"
        keyword="event_id"
        echo "File extension is .${filetype}"
else
        echo "Enter the technology type as specified above"
        exit -1
fi
ls ${TRACESINPUTDIR}| grep ${filetype}> ${tracesfilenames}
for each_file in `cat ${tracesfilenames}`
do
        echo "###File name is : ${each_file}" >> ${output}
        eachfilelog=${EACHLOGDIR}/${each_file}.txt
        echo "Processing for ${each_file}"
        $LTNGDECODER/ltng-decoder -f "${TRACESINPUTDIR}/${each_file}" > $eachfilelog
        echo 'Validation script for eLTE'
        for event_id in `cat $eventlist`
        do
                        iterations=`/bin/grep "$keyword: $event_id" $eachfilelog | wc -l`
                        if [[ $iterations -gt 0 ]]
                        then
                                        echo "Event ID exist: ${event_id}" >> ${output}
                        else
                                        echo "Event ID does not exist: ${event_id}" >> ${output}
                        fi
                done
done
}

ManipulateOutput()
{
cat ${output} | grep "Event ID exist" >>${successoutput}
cat ${output} | grep "Event ID does not exist" |sort | uniq>>${failedoutput}

for i in `cat ${failedoutput}| awk '{print $NF}'`;do count=`cat ${successoutput}| grep -w "$i" | wc -l` ;if [[ $count -eq 0 ]]; then echo $i>> $uncommon ;fi;done
}

Countevents()
{
missingcounters=`wc -l $uncommon`
totalcounters=`wc -l $eventlist`
echo "Total number of counters are: $totalcounters"
echo "Missing number of counters are: $missingcounters"

}


echo "Calling the unzip function"
UNZIP
echo "Calling the gunzip function"
GUNZIPFUN
echo "Calling the TRACESREAD function"
TRACESREAD ${eventlist}
echo "Calling the manipulate function"
ManipulateOutput ${eventlist}
Countevents

