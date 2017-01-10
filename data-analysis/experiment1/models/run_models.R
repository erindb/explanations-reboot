###
# This script runs all the webppl models
# that I compared against experiment 1 when it was
# run (2017 jan 6).
###

# load dependencies
source("~/Settings/startup.R")

# load design
design = read.csv("../../../data/full-explananations-elicitation-design.csv")

# define functions
get_cf_prob = function(story_number,
                       explanansVariable,
                       explanansValue,
                       explanandumVariable,
                       explanandumValue,
                       program_file_directory) {
  
  explanansPremiseValue = ifelse(explanansValue, "false", "true")
  explanandumConsequentValue = !explanandumValue
  
  program_file = paste(
    program_file_directory,
    "/lk",
    story_number,
    ifelse(
      program_file_directory=="rsa.onelink.booleans",
      explanandumVariable,
      ""),
    "/autoexpanded.wppl",
    sep="")
  message(program_file)
  
  model_var = paste(
    "function() {return counterfactual(0.53, {",
    explanansVariable,
    ": ",
    explanansPremiseValue,
    "});}",
    sep="")
  
  rs = webppl(
    program_file = program_file,
    model_var = model_var,
    inference_opts = list(method="enumerate"),
    packages = "./node_modules/jsUtils")
  
  cf_prob = sum(
    (rs %>% gather("variable", "value", -prob) %>%
       filter(variable==explanandumVariable &
                value==explanandumConsequentValue)
    )$prob)
  
  return(cf_prob)
}
get_rsa_rating = function(story_number,
                          explanansVariable,
                          explanansValue,
                          explanandumVariable,
                          explanandumValue,
                          program_file_directory) {
  
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
    program_file_directory,
    "/lk",
    story_number,
    ifelse(
      program_file_directory=="rsa.onelink.booleans",
      explanandumVariable,
      ""),
    "/autoexpanded.wppl",
    sep="")
  message(program_file)
  
  model_var = paste(
    "s2('",
    utterance,
    "', ",
    cost = 0,
    ", '",
    explanandum,
    "', ",
    innerUtterancePriorType = "'all_alternatives'",
    ", ",
    entailmentType = "'none'",
    ", ",
    innerRationalityParam = "1",
    ", ",
    outerRationalityParam = "1",
    ")",
    sep="")
  message(model_var)
  
  rs = webppl(
    program_file = program_file,
    model_var = model_var,
    inference_opts = list(method="enumerate"),
    packages = "./node_modules/jsUtils")
  
  rating = sum((rs %>% filter(support == utterance))$prob)
  
  return(rating)
}

## CF Prob with Base Uncertainty

cf_base = design %>% mutate(
  rating = mapply(get_cf_prob,
                  as.numeric(story),
                  explanansVariable,
                  explanansValue,
                  char(explanandumVariable),
                  explanandumValue,
                  "rsa.base.booleans")) %>%
  mutate(model = "cf",
         uncertainty = "state_only",
         entailmentType = "none")

write.csv(cf_base,
          "model_results/cf_base.csv",
          row.names=F)

## CF Prob with Structural Uncertainty

cf_onelink = design %>% mutate(
  rating = mapply(get_cf_prob,
                  as.numeric(story),
                  explanansVariable,
                  explanansValue,
                  char(explanandumVariable),
                  explanandumValue,
                  "rsa.onelink.booleans")) %>%
  mutate(model = "cf",
         uncertainty = "causal",
         entailmentType = "none")

write.csv(cf_onelink,
          "model_results/cf_onelink.csv",
          row.names=F)

## RSA with Base Uncertainty

rsa_rating = design %>% mutate(
  rating = mapply(get_rsa_rating,
                  as.numeric(story),
                  explanansVariable,
                  explanansValue,
                  char(explanandumVariable),
                  explanandumValue,
                  "rsa.base.booleans")) %>%
  mutate(model = "rsa",
         uncertainty = "state_only",
         entailmentType = "none")

write.csv(rsa_rating,
          "model_results/rsa_base.csv",
          row.names = F)

## RSA with Structural Uncertainty

rsa_onelink_rating = design %>% mutate(
  rating = mapply(get_rsa_rating,
                  as.numeric(story),
                  explanansVariable,
                  explanansValue,
                  char(explanandumVariable),
                  explanandumValue,
                  "rsa.onelink.booleans")) %>%
  mutate(model = "rsa",
         uncertainty = "causal",
         entailmentType = "none")

write.csv(rsa_onelink_rating,
          "model_results/rsa_onelink.csv",
          row.names = F)