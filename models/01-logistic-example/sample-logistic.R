library(ggplot2)
library(tidyr)
library(dplyr)
library(ggthemes)
library(RColorBrewer)
m = 0
b1 = 1
b2 = 0
sigma = 1
n.grid = 20
a = -5
b = 5

sigmoid = function(t) {
  return( 1 / (1 + exp(-t)) )
}

expand.grid(
  x1=seq(a,b,length.out=n.grid),
  x2=seq(a,b,length.out=n.grid)) %>%
  mutate(
    y = m + b1*x1 + b2*x2,
    # y = mapply(function(m,s) {return(rnorm(1, mean=m, sd=s))}, ydet, sigma),
    probs = sigmoid(y),
    labels = sapply(probs, function(p) {return(rbinom(1,1,p))})) %>%
  ggplot(., aes(x1, x2, fill=labels, colour=probs)) +
  geom_tile() +
  theme_few()

n = 10
data = data.frame(
  x1 = runif(n, min=a, max=b),
  x2 = runif(n, min=a, max=b),
  set = c(rep('train', n/2), rep('test', n/2))) %>%
  mutate(
    ydet = m + b1*x1 + b2*x2,
    y = mapply(function(m,s) {return(rnorm(1, mean=m, sd=s))}, ydet, sigma),
    probs = sigmoid(y),
    label = (sapply(probs, function(p) {return(rbinom(1,1,p))})==1))
ggplot(data, aes(x1, x2, colour=label, shape=set)) +
  geom_point(size=3) +
  geom_text(aes(label=1:nrow(data)), hjust=-0.8) +
  theme_few(base_size = 18) +
  scale_colour_brewer(palette = "Paired")
ggsave('logistic-data-plot.png', width=10, height=6)

data %>%
  select(x1, x2, label, set) %>%
  write.csv(., row.names = F, file = 'logistic-data.csv')