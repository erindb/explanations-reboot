library("rwebppl")
library("tidyr")
library("dplyr")

args = commandArgs(trailingOnly = TRUE)
i = args[1]

message(i)

design = read.csv("../../data/full-explananations-elicitation-design.csv") %>%
  filter(explanandumVariable != explanansVariable)

df = design[i,] %>%
  mutate(rating = mapply(function(story_number, explanansVariable,
                  explanandumVariable, utterance) {
    
    program_file_directory = "one-link-per-utterance"
    
    program_file = paste(
      program_file_directory,
      "/lk",
      story_number,
      explanandumVariable,
      explanansVariable,
      "/autoexpanded.wppl",
      sep="")
    message(program_file)
    
    model_var = paste(
      "s2({",
      "lexicon: ", lexicon = "'none'",
      ", actualUtterance: '", actualUtterance = utterance, "'",
      ", inferenceOpts: ", inferenceOpts = paste(
        "{literal: {method: 'MCMC', samples: 40000},",
        "s1: {method: 'enumerate'},",
        "listener: {method: 'MCMC', samples: 40000},",
        "s2: {method: 'enumerate'},",
        "worldModel: {method: 'MCMC', samples: 200000}}",
        sep=""
      ),
      ", utteranceSet: ", utteranceSet = "'even_more'",
      "})",
      sep="")
    message(model_var)
    
    rs = webppl(
      program_file = program_file,
      model_var = model_var,
      inference_opts = list(method="enumerate"))
    
    rating = sum((rs %>% filter(support == utterance))$prob)
    
    return(rating)
  }, story_number = as.numeric(story),
  explanansVariable = explanansVariable,
  explanandumVariable = explanandumVariable,
  utterance = as.character(utterance)))

write.csv(df, paste("results/", i, ".csv", sep=""), row.names=F)

