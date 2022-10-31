
#!/bin/bash
feedinput=${1}
keytabuser='svc-dehdlza-opex-uat'
BASE_DIR=/bigdata/datalake/opex/app/scripts/sharepoint
CURRENT_YEAR=$(date +"%Y")
CURRENT_MONTH=$(date +"%m")
CURRENT_DAY=$(date +"%d")
CURRENT_DATE=$(date +"%Y-%m-%d")

cd $BASE_DIR

VERSION=1
FEED=${feedinput,,}
FEEDS="gcms"
STR="dqrulelist"
if [[ ! ${FEED} =~ ^(dqrecordidentifier|dqrulelist|dquserlist|dqvoltroncdeweighting|cib_limitations_log_master|datarailsdatalakedatasets|myopex)$ ]]; then
        echo "INPUT SHOULD EITHER BE: dqrecordidentifier or dqrulelist or dquserlist or dqvoltroncdeweighting or cib_limitations_log_master or datarailsdatalakedatasets or myopex"
        exit 1
fi

echo ${CURRENT_YEAR}
echo ${CURRENT_MONTH}
echo ${CURRENT_DAY}
echo ${CURRENT_DATE}

kinit ${keytabuser} -kt /home/${keytabuser}/${keytabuser}.keytab
klist
RESULT=$?
if [ ${RESULT} -gt 0 ]; then
        echo Kinit failure ${RESULT}
        exit ${RESULT}
fi


#XML_FILE_PATH=/bigdatahdfs/datalake/raw/opex/landing/gcms/XMLFile/${FEED}_${CURRENT_YEAR}${CURRENT_MONTH}${CURRENT_DAY}.xml
#CSV_FILE_PATH=/bigdatahdfs/datalake/raw/opex/sharepoint/gcms/CSVFile/${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DAY}/v${VERSION}/${FEED}_${CURRENT_YEAR}${CURRENT_MONTH}${CURRENT_DAY}.csv
XML_FILE_PATH=/bigdatahdfs/datalake/raw/opex/landing/gcms/XMLFile/${FEED}_${CURRENT_YEAR}${CURRENT_MONTH}${CURRENT_DAY}.xml
CSV_FILE_PATH=/bigdatahdfs/datalake/raw/opex/sharepoint/gcms/CSVFile/${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DAY}/${FEED}_${CURRENT_YEAR}${CURRENT_MONTH}${CURRENT_DAY}.csv
#PARQUET_FILE_PATH=/bigdatahdfs/datalake/publish/opex/sharepoint/gcms/ParquetFile/enceladus_info_date=${CURRENT_DATE}
PARQUET_FILE_PATH=/bigdatahdfs/datalake/publish/opex/sharepoint/gcms/ParquetFile/year=${CURRENT_YEAR}/month=${CURRENT_MONTH}/day=${CURRENT_DAY}
STYLESHEET=/bigdata/datalake/opex/app/config/sharepoint/${FEED}_StyleSheet.xsl
TABLE_NAME="dl_myopex.t_sharepoint_${FEEDS,,}_d"

echo "Creating CSV file"
echo XML_FILE_PATH=${XML_FILE_PATH}
echo CSV_FILE_PATH=${CSV_FILE_PATH}
echo PARQUET_FILE_PATH=${PARQUET_FILE_PATH}
echo STYLESHEET=${STYLESHEET}
echo TABLE_NAME=${TABLE_NAME}

export SPARK_MAJOR_VERSION=2

spark-submit --class com.absa.cibriskdatarails.xmltocsvtoparquet.XMLtoCSV /bigdata/datalake/opex/app/bin/xmltocsvtoparquet-1.0-SNAPSHOT.jar \
"${STYLESHEET}" "${XML_FILE_PATH}" "${CSV_FILE_PATH}"
RESULT=$?

echo ${RESULT}

if [ ${RESULT} == 0 ]; then
        echo "CSV created successfully."
        echo "Creating Parquet file"
        export SPARK_MAJOR_VERSION=2

    if [ ${FEED} == ${STR} ];
        then
            spark-submit --class com.absa.cibriskdatarails.xmltocsvtoparquet.RefDQRules /bigdata/datalake/opex/app/bin/xmltocsvtoparquet-1.0-SNAPSHOT.jar \
            "${CSV_FILE_PATH}" "${PARQUET_FILE_PATH}" "${TABLE_NAME}"
            RESULT=$?
        else
            spark-submit --class com.absa.cibriskdatarails.xmltocsvtoparquet.CSVtoPARQUET /bigdata/datalake/opex/app/bin/xmltocsvtoparquet-1.0-SNAPSHOT.jar \
            "${CSV_FILE_PATH}" "${PARQUET_FILE_PATH}" "${TABLE_NAME}"
            RESULT=$?
    fi
fi

echo ==============================================================
echo Exiting with code $RESULT
echo ==============================================================
exit $RESULT
