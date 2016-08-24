library(rwebppl)
library(ggplot2)
library(tidyr)
library(dplyr)
library(jsonlite)
library(ggthemes)

theme_black = theme_few(18) + theme(
  plot.background = element_rect(fill="black", colour="black"),
  plot.title = element_text(colour="lightgray"),
  axis.line.x = element_line(colour="lightgray"),
  axis.line.y = element_line(colour="lightgray"),
  axis.ticks = element_line(colour="lightgray"),
  axis.text = element_text(colour="lightgray"),
  legend.title = element_text(colour="lightgray"),
  legend.text = element_text(colour="lightgray"),
  legend.background = element_rect(fill="black"),
  strip.text = element_text(colour="lightgray"),
  panel.border = element_rect(colour="black"),
  panel.background = element_rect(fill="black"),
  strip.background = element_rect(fill="black"),
  legend.position = "none",
  axis.title = element_text(colour="lightgray"))

theme.new = theme_set(theme_black)

scale_colour_black = function() {
  return(scale_colour_hue(c=55, l=35))
}
scale_fill_black = function() {
  return(scale_fill_hue(c=55, l=35))
}

# P(bacon | !smokeAlarm) == 0.487
# yup. with these params: inference_opts = list(method="MCMC", samples=10000, lag=100, burn=1000, verbose=T),
# we get:
# Iteration: 1010999 | Acceptance ratio: 0.8166
# support   prob
# 1   FALSE 0.5118
# 2    TRUE 0.4882
# and
# Iteration: 1010999 | Acceptance ratio: 0.7913
# support   prob
# 1   FALSE 0.5139
# 2    TRUE 0.4861
bacon = webppl(
  program_file = "bacon-expanded.wppl",
  # inference_opts = list(method="enumerate"),
  inference_opts = list(method="MCMC", samples=1000, lag=10, burn=100, verbose=T),
  model_var = "probBaconGivenNoSmokeAlarm",
  # output_format = "samples",
  packages = c("./node_modules/jsUtils")
)
bacon

cfs = webppl(
  program_file = "bacon-expanded.wppl",
  inference_opts = list(method="MCMC", samples=10000, lag=100, burn=1000, verbose=T),
  model_var = "imagineCounterfactualNoConditioning",
  output_format = "samples",
  packages = c("./node_modules/jsUtils")
)

cfs %>%
  select(c(actual.output.bacon, cf.output.bacon,
           actual.output.smokeAlarm, cf.output.smokeAlarm,
           actual.output.neighborsAngry, cf.output.neighborsAngry)) %>%
  gather("variable", "value") %>%
  separate(variable, c("world", "variable"), sep=".output.") %>%
  group_by(world, variable) %>%
  summarise(prob = mean(value)) %>%
  ggplot(., aes(x=variable, fill=variable, y=prob)) +
  geom_bar(stat="identity") +
  # theme(legend.position="right") +
  facet_grid(~world) +
  ylim(0,1) +
  scale_fill_black() +
  theme(axis.text=element_text(hjust=0, angle=-15),
        plot.margin=unit(c(0.1, 2, 0.2, 0.2), "cm"))
ggsave("bacon.counterfactuals.png", width=5, height=3)

cfs %>%
  gather("variable", "sampleParam",
         c(actual.latents.sampleParams.smokeAlarm, cf.latents.sampleParams.smokeAlarm,
           actual.latents.sampleParams.neighborsAngry, cf.latents.sampleParams.neighborsAngry)) %>%
  separate(variable, c("world", "variable"), sep=".latents.sampleParams.") %>%
  filter(variable=="smokeAlarm") %>%
  mutate(cf.output = cf.output.smokeAlarm) %>%
  ggplot(., aes(x=sampleParam, colour=world, fill=world)) +
  geom_histogram(position="dodge", binwidth=0.01) +
  # geom_density(alpha=1/3) +
  facet_grid(world~cf.output) +
  scale_colour_black() +
  scale_fill_black() +
  geom_vline(xintercept = 0.9, colour="lightgray") +
  annotate("text", x = 0.9, y = 150, colour="lightgray", label = "P(S|B)=0.9", hjust=1.1) +
  # geom_text(aes(group=1), x=0.9, y=0.5, colour="lightgray", label="P(smokeAlarm|bacon)=0.9") +
  ggtitle("smokeAlarm sampling") +
  theme(legend.position="right")
  ggsave("smokeAlarmSampling.png", width=8, height=6)
  
  cfs %>%
    gather("variable", "sampleParam",
           c(actual.latents.sampleParams.smokeAlarm, cf.latents.sampleParams.smokeAlarm,
             actual.latents.sampleParams.neighborsAngry, cf.latents.sampleParams.neighborsAngry)) %>%
    separate(variable, c("world", "variable"), sep=".latents.sampleParams.") %>%
    filter(variable=="neighborsAngry") %>%
    mutate(cf.output = cf.output.neighborsAngry) %>%
    ggplot(., aes(x=sampleParam, colour=world, fill=world)) +
    geom_histogram(position="dodge", binwidth=0.01) +
    # geom_density(alpha=1/3) +
    facet_grid(world~cf.output) +
    scale_colour_black() +
    scale_fill_black() +
    geom_vline(xintercept = 0.1, colour="lightgray") +
    annotate("text", x = 0.1, y = 150, colour="lightgray", label = "P(N|!S)=0.1", hjust=-0.1) +
    # geom_text(aes(group=1), x=0.9, y=0.5, colour="lightgray", label="P(smokeAlarm|bacon)=0.9") +
    ggtitle("neighborsAngry sampling") +
    theme(legend.position="right")
  ggsave("neighborsAngrySampling.png", width=8, height=6)

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
  ggtitle("cupcakes explanation")
  ggsave("best.explanation.111.brownies.png", width=5, height=4)

expl.rs.flowers = webppl(
  program_file = "agent-expanded-take2-actual-is-flowers.wppl",
  inference_opts = list(method="MCMC", samples=1000),
  model_var = "explanationModel",
  output_format = "samples",
  packages = c("./node_modules/jsUtils")
)

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