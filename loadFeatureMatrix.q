/ 71632 is the number of columns
/ "S" is string datatype
/ need to follow these steps if csv is too large to fit in RAM: https://code.kx.com/v2/kb/loading-from-large-files/
\t featureMatrix: (71632#"*";enlist csv) 0: `:featureMatrix.csv 
/	 \t 0N! meta featureMatrix: (71632#"S";enlist csv) 0: `:featureMatrix.csv 
/ 	 \t featureMatrix: (71632#"S";enlist csv) 0: `:featureMatrix.csv 
0N! featureMatrix
/ to save the q table back to csv, use the line below
/ \t (`$"featureMatrix2.csv") 0: "," featureMatrix