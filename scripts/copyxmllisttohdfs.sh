
#!/bin/bash

BASEDIR=$(dirname $0)
cd ${BASEDIR}
#. ./setenv.sh

KEYTABUSER=svc-dehdlza-opex-uat
KEYTAB=/home/${KEYTABUSER}/${KEYTABUSER}.keytab

kinit -kt ${KEYTAB} ${KEYTABUSER}

export SPARK_MAJOR_VERSION=2
whoami
VERSION=1
FEED=${1}
feedLower=${FEED,,}

if [[ ! ${feedLower} =~ ^(dqrecordidentifier|dqrulelist|dquserlist|dqvoltroncdeweighting|cib_limitations_log_master|datarailsdatalakedatasets|myopex)$ ]]; then
        echo "INPUT SHOULD EITHER BE: dqrecordidentifier or dqrulelist or dquserlist or dqvoltroncdeweighting or cib_limitations_log_master or datarailsdatalakedatasets or myopex"
        exit 1
fi
CURRENT_YEAR=$(date +"%Y")
CURRENT_MONTH=$(date +"%m")
CURRENT_DAY=$(date +"%d")
#XML_FILE_PATH=/bigdatahdfs/datalake/raw/opex/landing/gcms/XMLFile/${feedLower}_${CURRENT_YEAR}${CURRENT_MONTH}${CURRENT_DAY}.xml
XML_FILE_PATH=/bigdatahdfs/datalake/raw/opex/landing/gcms/XMLFile/${feedLower}_${CURRENT_YEAR}${CURRENT_MONTH}${CURRENT_DAY}.xml
echo XML file path is $XML_FILE_PATH

TOKEN=`curl --location --request POST 'https://accounts.accesscontrol.windows.net/5be1f46d-495f-465b-9507-996e8c8cdcb6/tokens/OAuth/2' --header 'Content-Type: application/x-www-form-urlencoded' --data-binary 'grant_type=client_credentials' --data-urlencode 'resource=00000003-0000-0ff1-ce00-000000000000/absacorp.sharepoint.com@5be1f46d-495f-465b-9507-996e8c8cdcb6' --data-urlencode 'client_id=0e21ba95-fe21-42a4-adbd-2feeb42d598e@5be1f46d-495f-465b-9507-996e8c8cdcb6' --data-urlencode 'client_secret=dm+/4NUOqZCN681rkIfV5kOnkDeoKYzyh7DQZQGm0NY=' | jq -r '.access_token'`
echo TOKEN:$TOKEN


case ${feedLower} in \
        dqrecordidentifier)
        SHAREPOINT_LIST="DQ%20Record%20Identifier" url="https://absacorp.sharepoint.com/sites/CIBCREDITRDARR/_api/Web/Lists/GetByTitle('$SHAREPOINT_LIST')/Items?\$top=4999";;\
        dqrulelist)
        SHAREPOINT_LIST="DQ%20Rule%20List" url="https://absacorp.sharepoint.com/sites/CIBCREDITRDARR/_api/Web/Lists/GetByTitle('$SHAREPOINT_LIST')/Items?\$top=4999";;\
        dquserlist)
        SHAREPOINT_LIST="DQ%20User%20List" url="https://absacorp.sharepoint.com/sites/CIBCREDITRDARR/_api/Web/Lists/GetByTitle('$SHAREPOINT_LIST')/Items?\$top=4999";;\
        dqvoltroncdeweighting)
        SHAREPOINT_LIST="DQ%20Voltron%20CDE%20Weighting" url="https://absacorp.sharepoint.com/sites/CIBCREDITRDARR/_api/Web/Lists/GetByTitle('$SHAREPOINT_LIST')/Items?\$top=4999";;\
        cib_limitations_log_master)
        SHAREPOINT_LIST="CIB_Limitations_Log_master" url="https://absacorp.sharepoint.com/sites/CIBCREDITLIMITATIONSFORUM/_api/Web/Lists/GetByTitle('$SHAREPOINT_LIST')/Items?\$top=4999";;\
        datarailsdatalakedatasets)
        SHAREPOINT_LIST="DataRails_DataLake_Dataset" url="https://absacorp.sharepoint.com/sites/ts_cibriskdata/_api/Web/Lists/GetByTitle('$SHAREPOINT_LIST')/Items?\$top=4999";;\
        myopex)
        SHAREPOINT_LIST="tblGCMS" url="https://absacorp.sharepoint.com/sites/MyWork59/_api/Web/Lists/GetByTitle('$SHAREPOINT_LIST')/Items?\$top=4999";;\
        *)

        echo No information provided for source XML file;;  \
        esac

echo $TOKEN
echo URL : ${url}
xml=`curl "${url}" --header "Authorization: Bearer $TOKEN"`
echo "*******************************************"
echo MODIFIEDDATE=`curl "${url}" --header "Authorization: Bearer $TOKEN" | grep -P -o -e'(?<=\"Edm.DateTime\">).*?(?=</d:LastItemModifiedDate>)'`
echo "*******************************************"


curl "${url}" --silent --header "Authorization: Bearer $TOKEN" -k -v | hadoop fs -put -f - ${XML_FILE_PATH}
hadoop fs -test -e ${XML_FILE_PATH}
EXITCODE=$?

echo exiting with code ${EXITCODE}
exit ${EXITCODE}

