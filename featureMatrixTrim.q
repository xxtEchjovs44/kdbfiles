/load and time the load
/ \t featureMatrix: (71632#"*";enlist csv) 0: `:../../../tensorflow/featureMatrix.csv
\t featureMatrix: (71632#"f";enlist csv) 0: `:../../../tensorflow/featureMatrix.csv

/remove pesky characters from feature names
/trimSpecialChar:{x:(`$ssr[;y;""] each trim each string cols x)xcol x}
/specialChars: ("[ ]"; "[/]"; "[_]"; "[(]"; "[)]"; "[[]"; "[]]"; "[+]"; "[-]"; "[*]"; "[/]")
/specialChars: (" "; "/"; "_"; "("; ")"; "["; "]"; "+"; "-"; "*"; "/")
/trimSpecialChar[featureMatrix;specialChars]
/first featureMatrix1

featureMatrix:(`$ssr[;" ";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[;"/";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[;"_";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[;"(";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[;")";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[; "[[]" ;""] each trim each string cols featureMatrix)xcol featureMatrix /special characters can be escaped by using square bracket on them!
featureMatrix:(`$ssr[;"[]]";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[;"[+]";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[;"[-]";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[;"[*]";""] each trim each string cols featureMatrix)xcol featureMatrix
featureMatrix:(`$ssr[;"[/]";""] each trim each string cols featureMatrix)xcol featureMatrix

/cast index from string to long
/featureMatrix: update index:"I"$index[i] from featureMatrix

/select 50 features from all features
featureCols: cols featureMatrix
featureCols1: 50#cols featureMatrix /adjust which cols to take
selectedFeatureCols:?[featureMatrix;();0b;featureCols1!featureCols1]
0N!selectedFeatureCols

/select chunk of rows from 50 features
chunk:select from selectedFeatureCols where i within 0 999
0N!chunk


/0N!"select index:"I"$index, gps_speed:featureCols[3], axis:featureCols[4] from featureMatrix where i within 0 10"
/0N!select index:"I"$index, gps_speed:featureCols[3], axis:featureCols[4] from featureMatrix where i within 0 10


/displayFeatureNames: {featureCols[x]}
/loadFeatures: displayFeatureNames[] 10+1til100
/select (displayFeatureNames[] 10+1til100) from featureMatrix

/ try this again
/select 'featureCols[10+1til100] from featureMatrix

/select featureCols[10+1til100] from featureMatrix