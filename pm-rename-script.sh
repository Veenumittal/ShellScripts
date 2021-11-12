OSSNAME=$1
DATE=$2
WORKDIR=`pwd`
gzfiles=$WORKDIR/gzfiles.txt
SRCFOLDER="/home/hljsgtbtbq/PM_FILES/$DATE"
DSTFOLDER="/data/rawdata/Ericsson/LTE/PM/operator14/"
>$gzfiles


GUNZIPF()
{
ls $SRCFOLDER | grep "gz" > ${gzfiles}
if [ -s ${gzfiles} ]
then
for filename in `cat ${gzfiles}`
        do
                cd $SRCFOLDER
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
echo "Gunzipping the gz files"
GUNZIPF
echo "Unzippping the files if exist"
cd $SRCFOLDER
for file in $(ls *.zip);do unzip $file ;done
for i in $( find $SRCFOLDER -type d );
do
    echo "i: $i"
    for files in ${i[@]}; do
    echo "files: $files"
    find $files -type f -name "A*.xml" -exec cp -rf {} $DSTFOLDER \;
    done
done

for foldername in `ls "${DSTFOLDER}" -1 | egrep "^A[[:digit:]]{8}\.[[:digit:]]{4}.*xml$" | cut -d'.' -f1 | cut -c2- | sort -u`
do
    mkdir ${DSTFOLDER}/${foldername}
    for roptime in `ls "${DSTFOLDER}" -1 | egrep "^A[[:digit:]]{8}\.[[:digit:]]{4}.*xml$" | cut -d'.' -f2 | cut -d'-' -f1 | sort -u`
    do
                cd ${DSTFOLDER}
                find ${DSTFOLDER} -name "A${foldername[@]}.${roptime[@]}*" -type f -exec mv -f {} "${foldername[@]}" \;
    done
done

for t in $(find ${DSTFOLDER} -mindepth 1 -maxdepth 1 -type d)
do
    for DATESTR in `ls "${t}" -1 | egrep "^A[[:digit:]]{8}\.[[:digit:]]{4}.*xml$" | cut -d'.' -f1 | cut -c2- | sort -u`
        do
        for ROPSTR in `ls "${t}" -1 | egrep "^A[[:digit:]]{8}\.[[:digit:]]{4}.*xml$" | cut -d'.' -f2 | cut -d'-' -f1 | sort -u`
                do
                NEWDATESTR=`echo "${DATESTR}" | cut -c3-`
                cd $t
                zip "${OSSNAME}_cpp_pm_${NEWDATESTR}${ROPSTR[@]}_01.zip" A${DATESTR}.${ROPSTR[@]}*.xml
                rm -rf A${DATESTR}.${ROPSTR[@]}*.xml
        done
    done
done

echo "Checking for number of files"
ls $SRCFOLDER | wc -l
echo "Checking for number of rops"
ls ${DSTFOLDER}/$DATE | wc -l
