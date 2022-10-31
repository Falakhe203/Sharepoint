# Sharepoint Datalake Ingestion to HDFS and HIVE

1. [copyxmllisttohdfs.sh.sh](scripts/copyxmllisttohdfs.sh): Copies the Sharepoint data to xml in hdfs.
1. [StyleSheet.xsl](scripts/StyleSheet.xsl): Formats the xml columns to match the csv data.
1. [ingestsharepointlist.sh](scripts/ingestsharepointlist.sh): Converts an xml file to csv and creates a parquet file. 
1. [CreateTable.txt](scripts/CreateTable.txt): Creates a HIVE table for the Sharepoint data.
1. Data is available in HDFS and HIVE.
