/ List of securities
seclist:([name:`ACME`ABC`DEF`XYZ]
 market:`US`UK`JP`US)

/ Distinct list of securities
secs: distinct exec name from seclist

n:5000
/ Data table
trade:([]sec:`seclist$n?secs;price:n?100.0;volume:100*10+n?20;exchange:5+n?2.0;date:2004.01.01+n?499)

/ Intra day tick data table
intraday:([]sec:`seclist$n?secs;price:n?100.0;volume:100*10+n?20;exchange:5+n?2.0;time:08:00:00.0+n?43200000)

/ Function with one input parameter
/ Return total trading volume for given security
totalvolume:{[stock] select volume from trade where sec = stock}

/ Function with two input parameters
/ Return total trading volume for given security with volume greate than 
/ given value
totalvolume2:{[stock;minvolume] select sum(volume) from trade where sec = stock, volume > minvolume}
