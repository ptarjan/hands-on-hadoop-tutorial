# make a new directory
mkdir count_example
cd count_example

# get the files (could be done with a git clone, but wget is more prevalent than git for now)
wget -o /dev/null http://github.com/ptarjan/hands-on-hadoop-tutorial/raw/master/mapper.py
wget -o /dev/null http://github.com/ptarjan/hands-on-hadoop-tutorial/raw/master/reducer.py
wget -o /dev/null http://github.com/ptarjan/hands-on-hadoop-tutorial/raw/master/reducer_numsort.py
wget -o /dev/null http://github.com/ptarjan/hands-on-hadoop-tutorial/raw/master/hamlet.txt
chmod u+x *.py

# run it locally
cat hamlet.txt | ./mapper.py | head
cat hamlet.txt | ./mapper.py | sort | ./reducer.py | head
cat hamlet.txt | ./mapper.py | sort | ./reducer.py | sort -k 2 -r -n | head
cat hamlet.txt | ./mapper.py | sort | ./reducer_numsort.py | head

# put the data in
hadoop fs -mkdir count_example
hadoop fs -put hamlet.txt count_example

# yahoo search specific - CHANGE TO YOUR OWN QUEUE
PARAMS=-Dmapred.job.queue.name=search_fast_lane

# run it
hadoop jar $HADOOP_HOME/hadoop-streaming.jar $PARAMS -mapper mapper.py -reducer reducer.py -input count_example/hamlet.txt -output count_example/hamlet_out -file mapper.py -file reducer.py 

# view the output
hadoop fs -ls count_example/hamlet_out/
hadoop fs -cat count_example/hamlet_out/* | head

# run the num sorted
hadoop jar $HADOOP_HOME/hadoop-streaming.jar $PARAMS -mapper mapper.py -reducer reducer_numsort.py -input count_example/hamlet.txt -output count_example/hamlet_numsort_out -file mapper.py -file reducer_numsort.py 

# view the output
mkdir out
hadoop fs -cat count_example/hamlet_numsort_out/* | sort -nrk 2 > out/hamlet_numsort.txt
head out/hamlet_numsort.txt

# test that hadoop worked
# apply the same sort to make sure ties are broken the same way
cat hamlet.txt | ./mapper.py | sort | ./reducer_numsort.py | sort -nrk 2 > out/hamlet_numsort_local.txt
diff out/hamlet_numsort.txt out/hamlet_numsort_local.txt


# EXTRA (wikipedia)
wget http://download.wikimedia.org/enwiki/latest/enwiki-latest-all-titles-in-ns0.gz
gunzip -c enwiki-latest-all-titles-in-ns0.gz | hadoop fs -put - count_example/wiki_titles
hadoop jar $HADOOP_HOME/hadoop-streaming.jar $PARAMS -mapper mapper.py -reducer reducer_numsort.py -input count_example/wiki_titles -output count_example/wiki_titles_out -file mapper.py -file reducer_numsort.py
hadoop fs -cat count_example/wiki_titles_out/* | head

# cleanup
hadoop fs -rmr count_example
cd ..
rm -r count_example
