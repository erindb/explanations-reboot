source("~/Settings/startup.R")

forward_sample = webppl(
  program_file = "model.wppl",
  model_var = "forward_sample",
  inference_opts = list(method="enumerate")
)

actual = forward_sample %>%
  rename(A = actual.A, B=actual.B, E=actual.E,
         AE = causal_parameters.AE, BE=causal_parameters.BE) %>%
  group_by(A, B, E, AE, BE) %>%
  summarise(prob=sum(prob)) %>%
  as.data.frame

actual %>% 
  ggplot(., aes(x=A, y=B, fill=E, alpha=prob)) +
  facet_grid(AE ~ BE) +
  geom_tile(position = 'dodge') +
  scale_fill_brewer(type = "qual", palette = 6)

actual %>% 
  ggplot(., aes(x=A, y=B, fill=E, alpha=prob)) +
  facet_grid(AE ~ BE) +
  geom_tile(position = 'dodge') +
  scale_fill_brewer(type = "qual", palette = 6)

# background_knowledge = "{A: true, B: true, E: true}"

# forward_sample %>%
#   mutate(AE = paste("A->E:", params.AE),
#          BE = paste("B->E:", params.BE)) %>%
#   ggplot(., aes(x=world.A, y=world.B, fill=world.E, alpha=prob)) +
#   facet_grid(AE ~ BE) +
#   geom_tile() +
#   scale_fill_brewer(type = "qual", palette = 6)
# 
# background_knowledge = "{A: true, B: true, E: true}"
# 
# background_knowledge_forward_sample = webppl(
#   program_file = "model.wppl",
#   model_var = paste("forward_sample(false, ", background_knowledge, ")", sep=""),
#   inference_opts = list(method="enumerate")
# )
# 
# background_knowledge_forward_sample %>%
#   mutate(AE = paste("A->E:", params.AE),
#          BE = paste("B->E:", params.BE)) %>%
#   ggplot(., aes(x=world.A, y=world.B, fill=world.E, alpha=prob)) +
#   facet_grid(AE ~ BE) +
#   geom_tile() +
#   scale_fill_brewer(type = "qual", palette = 6) +
#   ggtitle(background_knowledge)
# 
# background_knowledge_cf_forward_sample = webppl(
#   program_file = "model.wppl",
#   model_var = paste("forward_sample(true, ", background_knowledge, ")", sep=""),
#   inference_opts = list(method="enumerate")
# )
# 
# background_knowledge_cf_forward_sample %>%
#   mutate(AE = paste("A->E:", cfactual_params.AE),
#          BE = paste("B->E:", cfactual_params.BE)) %>%
#   ggplot(., aes(x=counterfactual.A, y=counterfactual.B, fill=counterfactual.E, alpha=prob)) +
#   facet_grid(AE ~ BE) +
#   geom_tile() +
#   scale_fill_brewer(type = "qual", palette = 6) +
#   ggtitle(paste("CF,", background_knowledge))