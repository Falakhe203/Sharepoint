# Sharepoint Datalake Ingestion to HDFS and HIVE

[copyxmllisttohdfs.sh.sh](scripts/copyxmllisttohdfs.sh): Copies the Sharepoint data to xml in hdfs.
[StyleSheet.xsl](scripts/StyleSheet.xsl): Formats the xml columns to match the csv data.
[ingestsharepointlist.sh](scripts/ingestsharepointlist.sh): Converts an xml file to csv and creates a parquet file. 
[Create Table.txt.sh](scripts/Create Table.txt): Creates a HIVE table for the Sharepoint data.
Data is available in HDFS and HIVE.
