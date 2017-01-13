source("~/Settings/startup.R")

design = read.csv("../../data/full-explananations-elicitation-design.csv")

# # s1_cached = list()
# cacheS1 = function(fn, params) {
#   if(params %in% names(s1_cached)) {
#     print(paste("retrieving", params))
#     return(s1_cached[[params]])
#   } else {
#     print(paste("caching", params))
#     rs = fn(params)
#     s1_cached[[params]] <<- rs
#     return(rs)
#   }
# }
# s1 = function(program_file) {
#   return(webppl(
#     program_file = program_file,
#     inference_opts = list(method="enumerate"),
#     model_var = paste(
#       "s1({actualUtterance: false, ",
#       "lexicon: 'none', ",
#       "utteranceSet: 'max'})",
#       sep="")
#   ))
# }
# 
# rs = webppl(
#   program_file = paste("rsa.onelink.booleans/lk", number=1,
#                        explanandum="A",
#                        "/autoexpanded.wppl", sep=""),
#   inference_opts = list(method="enumerate"),
#   model_var = paste(
#     "s2({actualUtterance: 'A because B', ",
#     "lexicon: 'none', ",
#     "utteranceSet: 'even_more'})",
#     sep="")
# )
# 
# runS1 = function(number, explanandumVariable, explanandumValue,
#                  explanansVariable, explanansValue) {
#   program_file = paste("rsa.onelink.booleans/lk", number,
#                        explanandum,
#                        "/autoexpanded.wppl", sep="")
#   utterance = paste(
#     ifelse(explanandumValue, "", "! "),
#     explanandumVariable,
#     " because ",
#     ifelse(explanansValue, "", "! "),
#     explanansVariable, sep="")
#   rs = cacheS1(s1, program_file)
#   return(sum((rs %>% filter(support==utterance))$prob))
# }

# rs1 = design %>%
#   mutate(rating = mapply(runS1, as.numeric(story),
#                          explanandumVariable, explanandumValue,
#                          explanansVariable, explanansValue))

s2 = function(program_file, utterance) {
  return(webppl(
    program_file = program_file,
    inference_opts = list(method="enumerate"),
    model_var = paste(
      "s2({actualUtterance: '",
      utterance,
      "', lexicon: 'none', utteranceSet: 'even_more'})",
      sep="")
  ))
}
# s2_cached = list()
# cacheS2 = function(fn, prog_file, utterance) {
#   params = paste(prog_file,utterance)
#   if(params %in% names(s2_cached)) {
#     print(paste("retrieving", params))
#     return(s2_cached[[params]])
#   } else {
#     print(paste("caching", params))
#     rs = fn(prog_file, utterance)
#     s2_cached[[params]] <<- rs
#     return(rs)
#   }
# }
runS2 = function(number, explanandumVariable, explanandumValue,
                 explanansVariable, explanansValue) {
  program_file = paste("rsa.onelink.booleans/lk", number,
                       explanandum,
                       "/autoexpanded.wppl", sep="")
  utterance = paste(
    ifelse(explanandumValue, "", "! "),
    explanandumVariable,
    " because ",
    ifelse(explanansValue, "", "! "),
    explanansVariable, sep="")
  rs = s2(program_file, utterance)
  matches_utterance = rs %>% filter(support==utterance)
  if (length(matches_utterance) > 1) {print(matches_utterance)}
  return(sum(matches_utterance$prob))
}

rs2 = design %>%
  mutate(rating = mapply(runS2, as.numeric(story),
                         explanandumVariable, explanandumValue,
                         explanansVariable, explanansValue))

# write.csv(rs1, "S1-onelink-even_more.csv")
write.csv(rs2, "S2-onelink-none-even_more.csv")

previously_used_values = read.csv(
  "../../data-analysis/experiment1/models/model_results/rsa_onelink.csv"
) %>% rename(previous=rating)

model_results = rs2 %>% rename(recheck = rating) %>%
  merge(., previously_used_values)
model_results$previous == model_results$recheck
cor(model_results$previous, model_results$recheck)

ggplot(model_results,
       aes(x=previous, y=recheck,
           colour=explanandumVariable,
           shape=explanansVariable)) +
  geom_abline(intercept=0, slope = 1) +
  geom_point() +
  facet_wrap(~story) +
  ylim(0,1) +
  xlim(0,1)

ggplot(model_results %>% filter(explanandumVariable != explanansVariable),
       aes(x=previous, y=recheck,
           colour=explanandumVariable,
           shape=explanansVariable)) +
  geom_abline(intercept=0, slope = 1) +
  geom_point() +
  facet_wrap(~story) +
  ylim(0,1) +
  xlim(0,1)

df = read.csv(
  "../../data/full-explananations-elicitation-aggregate-data.csv"
) %>% merge(., model_results)

# model_results %>%
#   filter(story=="story1" &
#            explanansVariable=="B" &
#            explanandumVariable=="A")

# df %>% ggplot(., aes(x=previous, y=mean_response,
#                      colour=explanandumVariable,
#                      shape=explanansVariable)) +
#   geom_abline(intercept=0, slope = 1) +
#   geom_point() +
#   facet_wrap(~story) +
#   ylim(0,1) +
#   xlim(0,1)

# df %>% ggplot(., aes(x=recheck, y=mean_response,
#                      colour=explanandumVariable,
#                      shape=explanansVariable)) +
#   geom_abline(intercept=0, slope = 1) +
#   geom_point() +
#   facet_wrap(~story) +
#   ylim(0,1) +
#   xlim(0,1)

