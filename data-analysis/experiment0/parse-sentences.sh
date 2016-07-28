directory='../../data/sentence-parses/'
filename=$directory'experiment0-sentences.txt'
filelines=`cat $filename`

while read -r line
do
	outputfile=`echo $line | sed -e "s/[.'\" ]//g"`
	## java -mx4g -cp "*:lib/*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer
	wget --post-data $line 'localhost:9000/?properties={"annotators": "tokenize,ssplit,pos,lemma,parse,depparse", "outputFormat": "json"}' -O - > $directory$outputfile
done <<< "$filelines"