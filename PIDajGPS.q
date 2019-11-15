/as of join test
/to count number of columns in csv:
/head -1 tensorflow/LOG00058.01.gps.csv | sed 's/[^,]//g' | wc -c
/head -1 tensorflow/LOG00058.01.csv | sed 's/[^,]//g' | wc -c

/start IPC TCP/IP broadcast on port 5001
\p 5001


/load data
"time & space taken to load CSVs"
/ \ts GPSData: ("f",(7-1)#"f";enlist csv) 0: `:../../tensorflow/LOG00058.01.gps.csv
/ \ts PIDData: ("ff",(32-2)#"f";enlist csv) 0: `:../../tensorflow/LOG00058.01.csv
\ts GPSData: ("f",(7-1)#"f";enlist csv) 0: `:../../tensorflow/train_020319_LOG00049_56_58_59_GPS.csv
\ts PIDData: ("ff",(32-2)#"f";enlist csv) 0: `:../../tensorflow/train_020319_LOG00049_56_58_59_PID.csv


/trim data
GPSData:(`$ssr[;" ";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[;"/";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[;"_";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[;"(";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[;")";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[; "[[]" ;""] each trim each string cols GPSData)xcol GPSData /special characters can be escaped by using square bracket on them!
GPSData:(`$ssr[;"[]]";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[;"[+]";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[;"[-]";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[;"[*]";""] each trim each string cols GPSData)xcol GPSData
GPSData:(`$ssr[;"[/]";""] each trim each string cols GPSData)xcol GPSData

PIDData:(`$ssr[;" ";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[;"/";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[;"_";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[;"(";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[;")";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[; "[[]" ;""] each trim each string cols PIDData)xcol PIDData /special characters can be escaped by using square bracket on them!
PIDData:(`$ssr[;"[]]";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[;"[+]";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[;"[-]";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[;"[*]";""] each trim each string cols PIDData)xcol PIDData
PIDData:(`$ssr[;"[/]";""] each trim each string cols PIDData)xcol PIDData


/adjust time data such that first time is 0us
if[res:(PIDData[`timeus] 0)<(GPSData[`timeus] 0); startTime:PIDData[`timeus] 0] /if PID start time is earlier than GPS start time
if[not res; startTime:GPSData[`timeus] 0] /else statement
delete res from `. /delete res variable that is no longer needed
/writing "GPSData[`timeus] 0" is the same as writing "first GPSData[`timeus]"

update timeus:timeus-startTime from `GPSData;

update timeus:timeus-startTime from `PIDData;

delete startTime from `. /delete startTime variable that is no longer needed


/convert us to ns
update timeus:1000*timeus[i] from `GPSData; /multiply us by 1000 /updates in place
GPSData:`timeus xcols GPSData /move timeus to front
GPSData:`timens xcol GPSData /rename timeus to timens

update timeus:1000*timeus[i] from `PIDData;
PIDData:`timeus xcols PIDData /move timeus to front
PIDData:`timens xcol PIDData /rename timeus to timens


/switch to maximum precision for aj operation
/ \P 0 /disabled

/cast from ns to timespan
update timens:`timespan$`long$timens[i] from `GPSData; /must cast to long first! /from long cast to timespan

update timens:`timespan$`long$timens[i] from `PIDData; 


/key PIDData and GPSData tables with timens column
`timens xkey `PIDData; 
`timens xkey `GPSData;

/as of join the PID log and GPS log
fullLog:aj0[`timens;GPSData;PIDData];

/create new log table trainingData of useful features only
trainingData: select timens,GPSspeedms,rcCommand0,rcCommand1,rcCommand2,rcCommand3,vbatLatestV,gyroADC0,gyroADC1,gyroADC2,accSmooth0,accSmooth1,accSmooth2,motor0,motor1,motor2,motor3 from fullLog

trainingData;

/delete table(s) that is no longer required from default namespace `.
/garbage collection not necessary???
/ https://stackoverflow.com/questions/34314997/how-to-delete-only-tables-in-kdb
/![`.;();0b;enlist `fullLog] /if only deleting fullLog (single table)
/![`.;();0b;enlist `fullLog]
![`.;();0b;(`fullLog;`GPSData;`PIDData)] /deletes tables fullLog, GPSData, PIDData


/in trainingData table, convert timestamps from ns to us
update timens:`int$timens%1000 from `trainingData;
trainingData:`timeus xcol trainingData /rename timeus to timens



/replace column GPSspeedms with GPSspeedkph
update GPSspeedkph:GPSspeedms*3.6 from `trainingData;
trainingData:`GPSspeedkph xcols trainingData; /place that new column in front
delete GPSspeedms from `trainingData;


/create new column of sample time deltas
update timeDeltaus:timeus[i+1]-timeus[i] from `trainingData;
trainingData:`timeDeltaus xcols trainingData; /place that new column in front
`timeus xkey `trainingData;

/find out average sample rate
/this query returns a table of single row
/this single row is then flipped to dictionary (list) with single item
/the 1st 'first' argument gets list from dictionary (read from right)
/the 2nd 'first argument' (read from right) gets the first element/atom in the list
/returns type of -9h to indicate it is a float atom
"average sample frequency"
averageFreq:reciprocal[averageFreq:first averageFreq:(first averageFreq:flip select avg timeDeltaus from trainingData where timeDeltaus>0)%1000000]
averageFreq