library(rwebppl)
library(ggplot2)
library(tidyr)
library(dplyr)
library(jsonlite)
library(ggthemes)

theme_black = theme_few() + theme(
  plot.background = element_rect(fill="black", colour="black"),
  axis.line.x = element_line(colour="lightgray"),
  axis.line.y = element_line(colour="lightgray"),
  axis.ticks = element_line(colour="lightgray"),
  axis.text = element_text(colour="lightgray"),
  strip.text = element_text(colour="lightgray"),
  panel.border = element_rect(colour="black"),
  panel.background = element_rect(fill="black"),
  strip.background = element_rect(fill="black"),
  legend.position = "none",
  axis.title = element_text(colour="lightgray"))

theme.new = theme_set(theme_black)

scale_colour_black = function() {
  return(scale_colour_hue(c=30, l=30))
}
scale_fill_black = function() {
  return(scale_fill_hue(c=30, l=30))
}

rs = webppl(
  program_file = "agent-expanded-take2.wppl",
  inference_opts = list(method="enumerate"),
  model_var = "imagineCounterfactualNoConditioning",
  packages = c("./node_modules/jsUtils")
)

rs %>%
  gather("world", "sampleParam",
         c(actual.latents.sampleParams.action, cf.latents.sampleParams.action)) %>%
  mutate(world=factor(world, labels=c("actual", "CF"))) %>%
  ggplot(aes(x=sampleParam, colour=world, fill=world)) +
  geom_histogram(alpha=1, position="dodge", binwidth=0.1) +
  facet_wrap(~cf.output) +
  scale_colour_black() +
  scale_fill_black() +
  ggtitle("sticky sampleParams") +
  ggsave("sticky.sampleParams.png", width=5, height=4)

rs %>% gather("world", "action",
              c(actual.output, cf.output)) %>%
  mutate(world=factor(world, labels=c("actual", "CF"))) %>%
  ggplot(aes(x=action, colour=world, fill=world)) +
  geom_bar() +
  facet_wrap(~ world) +
  scale_colour_black() +
  scale_fill_black() +
  theme(axis.text.x = element_text(angle = -20, hjust = 0)) +
  ggtitle("sticky output") +
  ggsave("sticky.output.png", width=5, height=3)

expl.rs = webppl(
  program_file = "agent-expanded-take2.wppl",
  inference_opts = list(method="enumerate"),
  model_var = "explanationModel",
  packages = c("./node_modules/jsUtils")
)

expl.rs %>%
  mutate(explanation=factor(
    support,
    levels=c("rationality", "utilityCoefs[\"prettiness\"]", "utilityCoefs[\"yumminess\"]"),
    labels=c("rationality=1", "should be pretty", "should be yummy"))) %>%
  ggplot(., aes(x=explanation, colour=explanation, fill=explanation, y=prob)) +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = -20, hjust = 0),
        legend.position="none") +
  ggtitle("cupcakes explanation") +
  scale_colour_black() +
  scale_fill_black()
  ggsave("best.explanation.111.cupcakes.png", width=5, height=4)

expl.rs.brownies = webppl(
  program_file = "agent-expanded-take2-actual-is-brownies.wppl",
  inference_opts = list(method="enumerate"),
  model_var = "explanationModel",
  packages = c("./node_modules/jsUtils")
)

expl.rs.brownies %>%
  mutate(explanation=factor(
    support,
    levels=c("rationality", "utilityCoefs[\"prettiness\"]", "utilityCoefs[\"yumminess\"]"),
    labels=c("rationality=1", "should be pretty", "should be yummy"))) %>%
  ggplot(., aes(x=explanation, colour=explanation, fill=explanation, y=prob)) +
  geom_bar(stat="identity") +
  scale_colour_black() +
  scale_fill_black() +
  theme(axis.text.x = element_text(angle = -20, hjust = 0),
        legend.position="none") +
  ggtitle("brownies explanation")
  ggsave("best.explanation.111.brownies.png", width=5, height=4)

  expl.rs.flowers = webppl(
    program_file = "agent-expanded-take2-actual-is-flowers.wppl",
    inference_opts = list(method="enumerate"),
    model_var = "explanationModel",
    packages = c("./node_modules/jsUtils")
  )

  
  expl.rs.flowers %>%
    mutate(explanation=factor(
      support,
      levels=c("rationality", "utilityCoefs[\"prettiness\"]", "utilityCoefs[\"yumminess\"]"),
      labels=c("rationality=1", "should be pretty", "should be yummy"))) %>%
    ggplot(., aes(x=explanation, colour=explanation, fill=explanation, y=prob)) +
    geom_bar(stat="identity") +
    scale_colour_black() +
    scale_fill_black() +
    theme(axis.text.x = element_text(angle = -20, hjust = 0),
          legend.position="none") +
    ggtitle("flowers explanation")
  ggsave("best.explanation.111.flowers.png", width=5, height=4)  

expl.rs.flowers %>%
  mutate(explanation=factor(
    support,
    levels=c("rationality", "utilityCoefs[\"prettiness\"]", "utilityCoefs[\"yumminess\"]"),
    labels=c("rationality=1", "should be pretty", "should be yummy"))) %>%
  ggplot(., aes(x=explanation, colour=explanation, fill=explanation)) +
  geom_bar(stat="count") +
  scale_colour_few() +
  scale_fill_few() +
  theme(axis.text.x = element_text(angle = -20, hjust = 0),
        legend.position="none") +
  ggtitle("flowers explanation") +
  ggsave("best.explanation.111.flowers.png", width=5, height=4)