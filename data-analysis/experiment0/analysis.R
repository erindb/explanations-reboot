library(tidyr)
library(dplyr)
library(ggplot2)
library(ggthemes)
source('theme_black.R')

theme_new = theme_set(theme_black(base_size=18))

# load data
df = read.csv('../../data/experiment0-production-anonymized-results-annotated.csv') %>%
  rename(assess=asses) %>%
  mutate(explanation = as.character(response),
         S = as.character(S),
         NV = as.character(NV),
         V = as.character(V),
         NC = as.character(NC),
         C = as.character(C),
         O = as.character(O),
         P = as.character(P))

# check that people are happy, speak english, and didn't have bugs in their expt:
df %>%
  group_by(workerid,
           problems, comments, fairprice, assess, enjoyment,
           age, education, language, gender,
           Browser, OS, screenH, screenW,
           time_in_minutes) %>%
  summarise %>%
  as.data.frame

# check how long people took overall:
print(mean(df$time_in_minutes))

# [graph: what percent of responses are within those events? (subjectively tagged)]
# [x: "video"; y: "% explanations in event list"]
df %>% group_by(video) %>%
  summarise(percent.in.video = mean(within.video.events=='yes')) %>%
  mutate(video = factor(video, levels=video[order(percent.in.video, decreasing=T)])) %>%
  ggplot(., aes(x=video, y=percent.in.video, fill=video)) +
  geom_bar(stat='identity', position='dodge', alpha=0.8) +
  scale_fill_brewer(type='qual', palette=6) +
  ylab('% Explanations in Event List') +
  xlab('Video')
ggsave('explanations-in-video.png', width=10, height=5)

# Do explanations reference observable events, mental states, lawlike principles?
df %>% group_by(video) %>%
  summarise(lawlike = sum(category=='lawlike'),
            mental.state = sum(category=='mental.state'),
            not.sure = sum(category=='not.sure'),
            observable = sum(category=='observable')) %>%
  gather('category', 'count', c(lawlike, mental.state, not.sure, observable)) %>%
  ggplot(., aes(x=video, y=count, fill=category)) +
  geom_bar(stat='identity', position='dodge', alpha=0.8) +
  scale_fill_brewer(type='qual', palette=6) +
  ylab('# Explanations') +
  xlab('Video')
ggsave('explanations-variable-categories.png', width=10, height=5)

# How do explanations cluster?
write.table(df$explanation, '../../data/sentence-parses/experiment0-sentences.txt',
            row.names=F, col.names=F)

# read big data (glove)
library(data.table)
word.vector.file = "/home/feste/cocolab/courses/y1q3-224u/cs224u/glove.6B/glove.6B.50d.txt"
glove = fread(word.vector.file, sep=' ', nrows=9900, header=F)
glove.df = data.frame(glove, row.names=1)

# glove embeddings function
get.glove = function(word) {
  if (is.na(word)) {
    return(rnorm(50, 0, 1))
  } else if (word %in% row.names(glove.df)) {
    vec = glove.df[word,]
    names(vec) = NULL
    row.names(vec) = NULL
    return(as.numeric(vec))
  } else {
    return(rnorm(50, 0, 1))
  }
}

pca.draw = function(sentence.df) {
  ## columns are items
  pc = (prcomp(t(sentence.df))$x)[,c('PC1','PC2')] %>% as.data.frame
  df$pc1 = pc[,1]
  df$pc2 = pc[,2]
  condpaste = function(a,b,c,d) {
    return(paste(c(a,b,c,d)[!is.na(c(a,b,c,d))], collapse=' '))
  }
  df %>% mutate(gloss = mapply(condpaste, S,V,C,O)) %>%
    ggplot(., aes(x=pc1, y=pc2, colour=video)) +
    geom_point() +
    geom_text(aes(label=gloss))
}

# average vectors to get sentence vector
get.sentence.embedding.plain.average = function(sentence) {
  words = strsplit(sentence, ' ')[[1]]
  embeddings = sapply(words, get.glove)
  return(apply(embeddings, 1, mean, na.rm=T))
}
sentences = sapply(df$explanation, get.sentence.embedding.plain.average)
pca.draw(sentences)

# # tfidf words
# library(tm)
# corpus = Corpus(VectorSource(df$explanation))
# cleanset = tm_map(corpus, removeWords, stopwords('english'))
# cleanset = tm_map(cleanset, stripWhitespace)
# dtm = DocumentTermMatrix(cleanset)
# dtm_tfxidf = weightTfIdf(dtm)
# m = as.matrix(dtm_tfxidf)
# rownames(m) = df$explanation
# pca.draw(as.data.frame(t(m)))

# concatenate with "caveman" structure (handwritten for now)
# get.caveman.concat.embedding = function(s, nv, v, nc, c, o, p) {
#   return(c(sapply(c(s, v, c, o, p), get.glove)))
# }
# sentences = mapply(get.caveman.concat.embedding,
#                    df$S, df$NV, df$V, df$NC, df$C, df$O, df$P)
# pc = (prcomp(t(sentences))$x)[,c('PC1','PC2')] %>% as.data.frame
# df$pc1 = pc[,1]
# df$pc2 = pc[,2]
# condpaste = function(a,b,c,d) {
#   return(paste(c(a,b,c,d)[!is.na(c(a,b,c,d))], collapse=' '))
# }
# df %>% mutate(gloss = mapply(condpaste, S,V,C,O)) %>%
#   ggplot(., aes(x=pc1, y=pc2, colour=video)) +
#   geom_point() +
#   geom_text(aes(label=gloss))

# # view individual explanations
# View(df[order(df$explanandum),] %>% select(explanandum, explanation))
# 
# # cluster responses with tsne or something
# 
# # read big data (glove)
# library(data.table)
# word.vector.file = "/home/feste/cocolab/courses/y1q3-224u/cs224u/glove.6B/glove.6B.50d.txt"
# glove = fread(word.vector.file, sep=' ', nrows=9900, header=F)
# glove.df = data.frame(glove, row.names=1)
# 
# # glove embeddings function
# get.glove = function(word) {
#   if (word %in% row.names(glove.df)) {
#     vec = glove.df[word,]
#     names(vec) = NULL
#     row.names(vec) = NULL
#     return(as.numeric(vec))
#   } else {
#     return(rep(NA, 50))
#   }
# }
# 
# # average vectors to get sentence vector
# # could maybe also weight by tfidf?
# get.sentence.embedding.plain.average = function(sentence) {
#   words = strsplit(sentence, ' ')[[1]]
#   embeddings = sapply(words, get.glove)
#   return(apply(embeddings, 1, mean, na.rm=T))
# }
# sentences = sapply(df$explanation, get.sentence.embedding.plain.average)
# 
# mydata = scale(t(data.frame(sentences)))
# 
# wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
# for (i in 2:30) wss[i] <- sum(kmeans(mydata, 
#                                      centers=i)$withinss)
# plot(1:30, wss, type="b", xlab="Number of Clusters",
#      ylab="Within groups sum of squares")
# 
# fit = kmeans(mydata, 5)
# clusters = data.frame(
#   sentence=names(fit$cluster),
#   cluster=fit$cluster,
#   row.names = 1:40)
# View(clusters[order(clusters$cluster),])
# 
# # library(NbClust)
# # wssplot <- function(data, nc=15, seed=1234){
# #   wss <- (nrow(data)-1)*sum(apply(data,2,var))
# #   for (i in 2:nc){
# #     set.seed(seed)
# #     wss[i] <- sum(kmeans(data, centers=i)$withinss)}
# #   plot(1:nc, wss, type="b", xlab="Number of Clusters",
# #        ylab="Within groups sum of squares")}
# # wssplot(mydata)
# # set.seed(1234)
# # nc = NbClust(mydata, min.nc=5, max.nc=15, method='kmeans')
# 
# # average, weighted by tfidf to get sentence vector
# 
# # library(tm)
# # corpus = Corpus(VectorSource(df$response))
# # cleanset = tm_map(corpus, removeWords, stopwords('english'))
# # cleanset = tm_map(cleanset, stripWhitespace)
# # dtm = DocumentTermMatrix(cleanset)
# # dtm_tfxidf = weightTfIdf(dtm)
# # m = as.matrix(dtm_tfxidf)
# # rownames(m) = 1:nrow(m)
# # norm_eucl = function(m) {
# #   return(m/apply(m, 1, function(x) {sum(x^2)^.5}))
# # }
# # m_norm = norm_eucl(m)
# # results = kmeans(m_norm, 12, 30)
# # 
# # clusters = 1:12
# # for (i in clusters) {
# #   cat("Cluster ", i, ":", findFreqTerms(dtm_tfxidf[results$cluster==i], 2), "\n\n")
# # }
