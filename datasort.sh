WORK_DIR=""
cd $WORK_DIR
for mqsc_file in `ls *.mqsc`
do
MQSC_DIR=`echo $i| awk -F ".mqsc" '{print $1}'`
#Below is the INPUT msqc FILE
INPUT_FILE="${WORK_DIR}/$mqsc_file"

if [[ ! -d $MQSC_DIR ]]
  then
		mkdir -p ${WORK_DIR}/${MQSC_DIR}
fi

#Provide your output file names here.
#LOCAL and INTERIM FILES WILL BE AUTOMATICALLY DELETED AFTER WORK IS DONE
QLOCAL_NAMES_FILE="${WORK_DIR}/${MQSC_DIR}/QLOCALNAMES.txt"
QLOCAL_INTERIM_FILE="${WORK_DIR}/${MQSC_DIR}/QLOCAL_INTERIM_FILE.txt"
QLOCAL_OUTPUT_FILE_NAME="${WORK_DIR}/${MQSC_DIR}/QLOCAL.csv"
>$QLOCAL_OUTPUT_FILE_NAME
>$QLOCAL_INTERIM_FILE
>$QLOCAL_NAMES_FILE

CHANNEL_NAMES_FILE="${WORK_DIR}/${MQSC_DIR}/CHANNELNAMES.txt"
CHANNEL_INTERIM_FILE="${WORK_DIR}/${MQSC_DIR}/CHANNEL_INTERIM_FILE.txt"
CHANNEL_OUTPUT_FILE_NAME="${WORK_DIR}/${MQSC_DIR}/CHANNEL.csv"
>$CHANNEL_OUTPUT_FILE_NAME
>$CHANNEL_INTERIM_FILE
>$CHANNEL_NAMES_FILE


LISTENER_NAMES_FILE="${WORK_DIR}/${MQSC_DIR}/LISTENERNAMES.txt"
LISTENER_INTERIM_FILE="${WORK_DIR}/${MQSC_DIR}/LISTENER_INTERIM_FILE.txt"
LISTENER_OUTPUT_FILE_NAME="${WORK_DIR}/${MQSC_DIR}/LISTENER.csv"
>$LISTENER_OUTPUT_FILE_NAME
>$LISTENER_INTERIM_FILE
>$LISTENER_NAMES_FILE

#Add or remove attributes below as required seperated by space
QLOCAL_ATT_NAME=(ACCTQ ALTDATE ALTTIME BOQNAME DEFREADA CURDEPTH CLWLUSEQ)
CHANNEL_ATT_NAME=(CHLTYPE DESCR RCVDATA SSLPEER)
LISTENER_ATT_NAME=(CHLTYPE DESCR RCVDATA SSLPEER)



#Main Code below. Do not change.
QLOCAL_FUNCTION()
{
echo -n "QLOCAL_NAME," >>$QLOCAL_OUTPUT_FILE_NAME
for each_attribute in "${QLOCAL_ATT_NAME[@]}"
do
    echo -n "${each_attribute}," >>$QLOCAL_OUTPUT_FILE_NAME
done
cat $INPUT_FILE| grep -nw "^DEFINE QLOCAL" > $QLOCAL_NAMES_FILE
while read -r line
do
    linestoskip=`echo $line |awk -F ":" '{print $1}'`
    linestostart=`expr $linestoskip + 1`
    linetoscan=`echo $line |awk -F ":" '{print $2}'`
    echo $linetoscan >> $QLOCAL_INTERIM_FILE
    Counter=0
    while read -r mainline
    do
            if [[ $mainline =~ ^DEFINE ]]
            then
                break
            else
                echo $mainline >>$QLOCAL_INTERIM_FILE
            fi
     done < <(tail -n "+$linestostart" $INPUT_FILE)
done < $QLOCAL_NAMES_FILE
while read -r line
do
    split_line=`echo $line | awk -F "(" '{print $1}'`
    if [[ $split_line == "DEFINE QLOCAL" ]]
    then
        echo "" >>$QLOCAL_OUTPUT_FILE_NAME
        QLOCAL_NAME=`echo $line  | awk -F "(" '{print $2}' | awk -F ")" '{print $1}'`
        echo -n "${QLOCAL_NAME}," >>$QLOCAL_OUTPUT_FILE_NAME
    else
        ATTRIBUTE_KEY=`echo $line | awk -F "(" '{print $1}'`
        for each_attribute in "${QLOCAL_ATT_NAME[@]}"
        do
            if [[ $ATTRIBUTE_KEY == $each_attribute ]]
            then
                ATTRIBUTE_VALUE=`echo $line | awk -F "(" '{print $2}' | awk -F ")" '{print $1}'`
                echo -n "${ATTRIBUTE_VALUE}," >>$QLOCAL_OUTPUT_FILE_NAME
            fi
        done
    fi
done <$QLOCAL_INTERIM_FILE
rm $QLOCAL_NAMES_FILE
rm $QLOCAL_INTERIM_FILE
}

#Below is the code for CHANNEL
CHANNEL_FUNCTION()
{
echo -n "CHANNEL_NAME," >>$CHANNEL_OUTPUT_FILE_NAME
for each_attribute in "${CHANNEL_ATT_NAME[@]}"
do
    echo -n "${each_attribute}," >>$CHANNEL_OUTPUT_FILE_NAME
done
cat $INPUT_FILE| grep -nw "^DEFINE CHANNEL" > $CHANNEL_NAMES_FILE
while read -r line
do
    linestoskip=`echo $line |awk -F ":" '{print $1}'`
    linestostart=`expr $linestoskip + 1`
    linetoscan=`echo $line |awk -F ":" '{print $2}'`
    echo $linetoscan >> $CHANNEL_INTERIM_FILE
    Counter=0
    while read -r mainline
    do
            if [[ $mainline =~ ^DEFINE ]]
            then
                break
            else
                echo $mainline >>$CHANNEL_INTERIM_FILE
            fi
     done < <(tail -n "+$linestostart" $INPUT_FILE)
done < $CHANNEL_NAMES_FILE
while read -r line
do
    split_line=`echo $line | awk -F "(" '{print $1}'`
    if [[ $split_line == "DEFINE CHANNEL" ]]
    then
        echo "" >>$CHANNEL_OUTPUT_FILE_NAME
        CHANNEL_NAME=`echo $line  | awk -F "(" '{print $2}' | awk -F ")" '{print $1}'`
        echo -n "${CHANNEL_NAME}," >>$CHANNEL_OUTPUT_FILE_NAME
    else
        ATTRIBUTE_KEY=`echo $line | awk -F "(" '{print $1}'`
        for each_attribute in "${CHANNEL_ATT_NAME[@]}"
        do
            if [[ $ATTRIBUTE_KEY == $each_attribute ]]
            then
                ATTRIBUTE_VALUE=`echo $line | awk -F "(" '{print $2}' | awk -F ")" '{print $1}'`
                echo -n "${ATTRIBUTE_VALUE}," >>$CHANNEL_OUTPUT_FILE_NAME
            fi
        done
    fi
done <$CHANNEL_INTERIM_FILE
rm $CHANNEL_NAMES_FILE
rm $CHANNEL_INTERIM_FILE
}
#Below is the code for LISTENER
LISTENER_FUNCTION()
{
echo -n "LISTENER_NAME," >>$LISTENER_OUTPUT_FILE_NAME
for each_attribute in "${LISTENER_ATT_NAME[@]}"
do
    echo -n "${each_attribute}," >>$LISTENER_OUTPUT_FILE_NAME
done
cat $INPUT_FILE| grep -nw "^DEFINE LISTENER" > $LISTENER_NAMES_FILE
while read -r line
do
    linestoskip=`echo $line |awk -F ":" '{print $1}'`
    linestostart=`expr $linestoskip + 1`
    linetoscan=`echo $line |awk -F ":" '{print $2}'`
    echo $linetoscan >> $LISTENER_INTERIM_FILE
    Counter=0
    while read -r mainline
    do
            if [[ $mainline =~ ^DEFINE ]]
            then
                break
            else
                echo $mainline >>$LISTENER_INTERIM_FILE
            fi
     done < <(tail -n "+$linestostart" $INPUT_FILE)
done < $LISTENER_NAMES_FILE
while read -r line
do
    split_line=`echo $line | awk -F "(" '{print $1}'`
    if [[ $split_line == "DEFINE LISTENER" ]]
    then
        echo "" >>$LISTENER_OUTPUT_FILE_NAME
        LISTENER_NAME=`echo $line  | awk -F "(" '{print $2}' | awk -F ")" '{print $1}'`
        echo -n "${LISTENER_NAME}," >>$LISTENER_OUTPUT_FILE_NAME
    else
        ATTRIBUTE_KEY=`echo $line | awk -F "(" '{print $1}'`
        for each_attribute in "${LISTENER_ATT_NAME[@]}"
        do
            if [[ $ATTRIBUTE_KEY == $each_attribute ]]
            then
                ATTRIBUTE_VALUE=`echo $line | awk -F "(" '{print $2}' | awk -F ")" '{print $1}'`
                echo -n "${ATTRIBUTE_VALUE}," >>$LISTENER_OUTPUT_FILE_NAME
            fi
        done
    fi
done <$LISTENER_INTERIM_FILE
rm $LISTENER_NAMES_FILE
rm $LISTENER_INTERIM_FILE
}

QLOCAL_FUNCTION
CHANNEL_FUNCTION
LISTENER_FUNCTION
done
