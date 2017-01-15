### on the subset of data based on lk,

# load dependencies
source("~/Settings/startup.R")

# load design
design = read.csv("../../data/lk-explanations-design.csv")

get_rsa_rating = function(story_number,
                          explanansVariable,
                          explanandumVariable,
                          utterance,
                          program_file_directory) {
  
  program_file = paste(
    "models/",
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
    ", utteranceSet: ", utteranceSet = "'even_more'",
    "})",
    sep="")
  message(model_var)
  
  stopifnot(file.exists(program_file))
  rs = webppl(
    program_file = program_file,
    model_var = model_var,
    inference_opts = list(method="enumerate"))
  
  rating = sum((rs %>% filter(support == utterance))$prob)
  
  return(rating)
}

rsa_onelink = design %>%
  filter(char(explanandumVariable) != char(explanansVariable)) %>%
  mutate(
    rating = mapply(get_rsa_rating,
                    story_number = as.numeric(story),
                    explanansVariable = char(explanansVariable),
                    explanandumVariable = char(explanandumVariable),
                    utterance = char(utterance),
                    program_file_directory = "one-link-per-utterance"))

## I only changed 2, 3, 5 and maybe 6
# write.csv(rsa_onelink, "models/model_results/rsa-onelink-lksubset-improveduncertainty.csv", row.names=F)