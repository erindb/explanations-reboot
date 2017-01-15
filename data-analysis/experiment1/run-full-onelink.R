
# load dependencies
source("~/Settings/startup.R")

# load design
design = read.csv("../../data/full-explananations-elicitation-design.csv")

s2 = function(program_file, model_var) {
  return(webppl(
    program_file = program_file,
    model_var = model_var,
    inference_opts = list(method="enumerate")))
}
memS2 = memoise(s2)

get_rsa_rating = function(story_number,
                          explanansVariable,
                          explanansValue,
                          explanandumVariable,
                          explanandumValue,
                          program_file_directory,
                          utteranceCheck) {
  
  explanansPremiseValue = ifelse(explanansValue, "false", "true")
  explanandumConsequentValue = !explanandumValue
  explanandum = paste(
    ifelse(explanandumValue, "", "! "),
    explanandumVariable,
    sep="")
  explanans = paste(
    ifelse(explanansValue, "", "! "),
    explanansVariable,
    sep="")
  
  utterance = paste(
    explanandum,
    " because ",
    explanans,
    sep = "")
  
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
  rs = memS2(program_file, model_var)
  
  rating = sum((rs %>% filter(support == utterance))$prob)
  
  return(rating)
}

rsa_onelink = design %>%
  filter(explanandumVariable != explanansVariable) %>%
  # filter(story == "story1" & explanandumVariable=="A") %>%
  mutate(
    rating = mapply(get_rsa_rating,
                    story_number = as.numeric(story),
                    explanansVariable = explanansVariable,
                    explanansValue = explanansValue,
                    explanandumVariable = explanandumVariable,
                    explanandumValue = explanandumValue,
                    program_file_directory = "one-link-per-utterance",
                    utteranceCheck=utterance))

# write.csv(rsa_onelink, "models/model_results/rsa_onelink_s2_improveduncertainty_noentailments_uevenmore", row.names=F)
