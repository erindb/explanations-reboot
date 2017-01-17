library("rwebppl")
library("tidyr")
library("dplyr")

args = commandArgs(trailingOnly = TRUE)
i = args[1]

message(i)
design = read.csv("../../data/full-explananations-elicitation-design.csv") %>%
  filter(explanandumVariable != explanansVariable)
input = design[i,]

program_file_directory = "one-link-per-utterance"
story_number = as.numeric(input$story)[[1]]
explanansVariable = input$explanansVariable[[1]]
explanandumVariable = input$explanandumVariable[[1]]
utterance = as.character(input$utterance)[[1]]

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
  # ", utteranceSet: ", utteranceSet = "'even_more'",
  "})",
  sep="")
message(model_var)

rs = webppl(
  program_file = program_file,
  model_var = model_var,
  inference_opts = list(method="enumerate"))

rating = sum((rs %>% filter(support == utterance))$prob)

df = data.frame(
  story_number = story_number,
  explanansVariable = explanansVariable,
  explanandumVariable = explanandumVariable,
  rating = rating
)

write.csv(df, paste("results/lk", story_number,
                    explanandumVariable, explanansVariable,
                    ".csv",
                    sep=""), row.names=F)

