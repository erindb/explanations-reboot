
# load dependencies
source("~/Settings/startup.R")

# load design
design = read.csv("../../data/full-explananations-elicitation-design.csv")

call.webppl = function(program_file, model_var) {
  return(webppl(
    program_file = program_file,
    model_var = model_var,
    inference_opts = list(method="enumerate")))
}
mem.call.webppl = memoise(call.webppl)

get_literal_rating_of_actual_world = function(
  story_number, explanansVariable, explanandumVariable,
  program_file_directory, utterance) {
  
  program_file = paste(
    "models/", program_file_directory,
    "/lk", story_number, explanandumVariable, explanansVariable,
    "/autoexpanded.wppl",
    sep="")
  message(program_file)
  stopifnot(file.exists(program_file))
  
  model_var = paste(
    "literal({",
    "utterance: '", utterance = utterance, "'",
    ", lexicon: ", lexicon = "'none'",
    "})",
    sep="")
  message(model_var)
  
  rs = mem.call.webppl(program_file, model_var)
  
  obs = webppl(program_file = paste(
    "models/", program_file_directory,
    "/lk", story_number, explanandumVariable, explanansVariable,
    "/observations.wppl", sep=""))
  flat.obs = c()
  filtered.rs = rs
  for (paramsType in names(obs)) {
    subobs = obs[[paramsType]]
    for (param in names(subobs)) {
      value = subobs[[param]]
      variable = paste(paramsType, param, sep=".")
      flat.obs[variable] = value
      filtered.rs = filtered.rs %>% filter(.[[variable]] == value)
    }
  }
  rating = sum(filtered.rs$prob)
  
  return(rating)
}

story5.literal = design %>%
  filter(explanandumVariable != explanansVariable) %>%
  filter(story == "story5") %>%
  # filter(explanandumVariable=="A" & explanansVariable=="B") %>%
  mutate(
    posterior = mapply(get_literal_rating_of_actual_world,
                    story_number = as.numeric(story),
                    explanansVariable = explanansVariable,
                    explanandumVariable = explanandumVariable,
                    program_file_directory = "one-link-per-utterance",
                    utterance=utterance),
    prior = mapply(get_literal_rating_of_actual_world,
                   story_number = as.numeric(story),
                   explanansVariable = explanansVariable,
                   explanandumVariable = explanandumVariable,
                   program_file_directory = "one-link-per-utterance",
                   utterance="null"))

# write.csv(story5.literal, "models/model_results/story5-literal.csv", row.names=F)
