source("~/Settings/startup.R")
library(memoise)

design = read.csv("../../data/full-explananations-elicitation-design.csv")

# webppl(
#   program_file = paste("rsa.onelink.booleans/lk", number=1,
#                        explanandum="B",
#                        "/autoexpanded.wppl", sep=""),
#   inference_opts = list(method="enumerate"),
#   model_var = paste(
#     "s2({actualUtterance: '",
#     utterance="B because A",
#     "', lexicon: 'none', utteranceSet: 'even_more'})",
#     sep="")
# )

s2 = function(program_file, utterance, explanandum) {
  model_var = paste(
    "s2({actualUtterance: '",
    utterance,
    "', lexicon: 'none', utteranceSet: 'even_more'})",
    sep="")
  print(model_var)
  return(webppl(
    program_file = program_file,
    inference_opts = list(method="enumerate"),
    model_var = model_var
  ))
}
# s2 = function(program_file, utterance, explanandum) {
#   model_var = paste(
#     "s2(",
#     "'", base_utterance = utterance, "'",
#     ", ",
#     cost = 0,
#     ", ",
#     "'", explanandum = explanandum, "'",
#     ", ",
#     innerUtterancePriorType = "'all_alternatives'",
#     ", ",
#     entailmentType = "'none'",
#     ", ",
#     innerRationalityParam=1,
#     ", ",
#     outerRationalityParam=1,
#     ")",
#     sep="")
#   message(model_var)
#   message(program_file)
#   return(webppl(
#     program_file = program_file,
#     inference_opts = list(method="enumerate"),
#     model_var = model_var
#   ))
# }
memS2 <- memoise(s2)

runS2 = function(number, explanandumVariable, explanandumValue,
                 explanansVariable, explanansValue) {
  
  explanandum = paste(ifelse(explanandumValue, "", "! "),
                      explanandumVariable, sep="")
  explanans = paste(ifelse(explanansValue, "", "! "),
                    explanansVariable, sep="")
  program_file = paste("rsa.onelink.booleans/lk", number,
                       explanandumVariable,
                       "/autoexpanded.wppl", sep="")
  
  utterance = paste(
    explanandum,
    " because ",
    explanans, sep="")
  
  print(paste(number, utterance))
  print(program_file)
  
  rs = memS2(program_file, utterance, explanandum)
  matches_utterance = rs %>% filter(support==utterance)
  if (nrow(matches_utterance) > 1) {print(matches_utterance)}
  return(sum(matches_utterance$prob))
}

rs2 = design %>%
  # filter(story == "story6" & explanandumVariable=="C") %>%
  filter(story == "story1" & explanandumVariable=="B") %>%
  mutate(rating = mapply(runS2, as.numeric(story),
                         char(explanandumVariable),
                         explanandumValue,
                         char(explanansVariable),
                         explanansValue))

previous_model_results = read.csv(
  paste("../../data-analysis/experiment1/",
        "models/model_results/rsa_onelink.csv",
        sep="")
) %>%
  # filter(story == "story6" & explanandumVariable=="C") %>%
  filter(story == "story1" & explanandumVariable=="B") %>%
  rename(previous=rating)

all_model_results = merge(rs2, previous_model_results)

all_model_results %>%
  ggplot(., aes(x=rating, y=previous,
                colour=explanandumVariable,
                shape=explanansVariable)) +
  facet_wrap(~story) +
  geom_abline(intercept = 0, slope = 1) +
  geom_point() + ylim(0,1) + xlim(0,1)

forget(memS2)

"B because A"
target = 0.2483437
orig = 0.3659193
changing_utterance_prior = 0.3659193
also_changing_meaning = 0.3659193
also_changing_matchingFactor = 0.3659193
also_changing_reducetomatchingkeys = 0.3659193
also_changing_literal_and_meaning = 0.3659193
changing_everything = 0.2463893 #(almost the same as target)

## once I figured out that I was running the wrong file,
## I was able to exactly reproduce the previous model's behavior.
## then, I kept literal and meaning functions the same
## but started changing functions higher up the chain.

target = 0.2483437
orig = 0.3660331
changing_s1 = NA

all_model_results
