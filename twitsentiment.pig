
You need to stream data from twitter and you need to perform sentiment analysis on the data.


--Associated Data Files
--https://acadgild.com/blog/sentiment-analysis-on-tweets-using-afinn-dictionary/

--Problem Statement
--Follow the below blog and perform sentiment analysis using Mapreduce/pig
--https://acadgild.com/blog/sentiment-analysis-on-tweets-using-afinn-dictionary/
--Submit the screen shots of the final results with the Source code.

REGISTER '/home/acadgild/elephant-bird-hadoop-compat-4.1.jar';
REGISTER '/home/acadgild/elephant-bird-pig-4.1.jar';
REGISTER '/home/acadgild/json-simple-1.1.1.jar';
 	
load_tweets = LOAD '/home/acadgild/flumesrc' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') AS myMap;
dump load_tweets;

extract_details = FOREACH load_tweets GENERATE myMap#'id' as id,myMap#'text' as text;
dump extract_details;

tokens = foreach extract_details generate id,text, FLATTEN(TOKENIZE(text)) As word;
dump tokens;

dictionary = load '/home/acadgild/AFINN.txt' using PigStorage('\t') AS(word:chararray,rating:int);
dump dictionary;

word_rating = join tokens by word left outer, dictionary by word using 'replicated';
dump word_rating;


rating = foreach word_rating generate tokens::id as id,tokens::text as text, dictionary::rating as rate;
dump rating;

word_group = group rating by (id,text);
dump word_group;

avg_rate = foreach word_group generate group, AVG(rating.rate) as tweet_rating;
dump avg_rate;

positive_tweets = filter avg_rate by tweet_rating>=0;
dump positive_tweets;
