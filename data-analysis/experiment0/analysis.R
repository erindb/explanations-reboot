library(tidyr)
library(dplyr)

df = read.csv('../../data/experiment0-production-anonymized-results.csv') %>%
  rename(assess=asses) %>%
  mutate(response = as.character(response))

df %>%
  group_by(workerid,
           problems, comments, fairprice, assess, enjoyment,
           age, education, language, gender,
           Browser, OS, screenH, screenW,
           time_in_minutes) %>%
  summarise %>%
  as.data.frame

print(mean(df$time_in_minutes))

View(df[order(df$explanandum),] %>% select(explanandum, response))

# cluster responses with tsne or something
word.vector.file = "glove.6B.300d.txt"


# library(tm)
# corpus = Corpus(VectorSource(df$response))
# cleanset = tm_map(corpus, removeWords, stopwords('english'))
# cleanset = tm_map(cleanset, stripWhitespace)
# dtm = DocumentTermMatrix(cleanset)
# dtm_tfxidf = weightTfIdf(dtm)
# m = as.matrix(dtm_tfxidf)
# rownames(m) = 1:nrow(m)
# norm_eucl = function(m) {
#   return(m/apply(m, 1, function(x) {sum(x^2)^.5}))
# }
# m_norm = norm_eucl(m)
# results = kmeans(m_norm, 12, 30)
# 
# clusters = 1:12
# for (i in clusters) {
#   cat("Cluster ", i, ":", findFreqTerms(dtm_tfxidf[results$cluster==i], 2), "\n\n")
# }