
# args = commandArgs(trailingOnly = TRUE)
# i = args[1]

# i ranges from 1 to 144
# requires `lk-flat.wppl`
# requires `alternative_causal_structures.csv`
# requires `model_parameters.csv`

library("rwebppl")
library("tidyr")
library("dplyr")

time = format(Sys.time(), "%Y.%m.%d_%H.%M")

graphs = list(
  `A, B` = ".",
  `A->B` = ">",
  `B->A` = "<",
  `A, B, C` = ". . .",
  `A->B->C` = "> > .",
  `A->B, C` = "> . .",
  `B->A, C` = "< . .",
  `A<-B->C` = "< > .",
  `A, B->C` = ". > .",
  `A, C->B` = ". < .",
  `A->B<-C` = "> < .",
  `A->C, B` = ". . >",
  `A->C<-B` = ". > >",
  `B<-A->C` = "> . >",
  `C->A, B` = ". . <",
  `C->A->B` = "> . <",
  `B->C->A` = ". > <",
  `A->B->C->D` = "> . . > . >",
  `B<-A->C->D` = "> > . . . >",
  `B->A, C->D` = "< . . . . >",
  `A->B, C->D` = "> . . . . >",
  `B->A->C->D` = "< > . . . >",
  `A<-B->C->D` = "< . . > . >",
  `A->(C->D)<-B` = ". > . > . >",
  `A, B->C->D` = ". . . > . >",
  `A, B, C->D` = ". . . . . >",
  `B->(A<-C->D)` = ". < . > . >",
  `A->(B<-C->D)` = ". > . < . >",
  `A->C<-B, D` = ". > . > . .",
  `(A, B, C)->D` = ". . > . > >",
  `A, B->C, D` = ". . . > . .",
  `A, B->C->D` = ". . . > . >",
  `A, B->D<-C` = ". . . . > >",
  `A->C, B->D` = ". > . . > .",
  `A->C, D->B` = ". > . . < .",
  `A->C->D->B` = ". > . . < >",
  `A->C<-B->D` = ". > . > > .",
  `A->C<-B<-D` = ". > . > < .",
  `A->D, B->C` = ". . > > . .",
  `A->D<-C, B` = ". . > . . <",
  `B, A->C, D` = ". > . . . .",
  `B, A->C->D` = ". > . . . >",
  `B->C, D->A` = ". . < > . .",
  `B->C->D->A` = ". . < > . >",
  `D->A->C<-B` = ". > < > . .",
  `D<-A->C<-B` = ". > < > . ."
)
str2world = function(str) {
  links = strsplit(str, " ")[[1]]
  if (length(links)==1) {
    return(paste("{AB: '", links[1], "'}", sep=""))
  } else if (length(links)==3) {
    return(paste("{ AB: '", links[1], "'",
                 ", BC: '", links[2], "'",
                 ", AC: '", links[3], "'",
                 "}", sep=""))
  } else if (length(links)==6) {
    print("error 2450913: not implemented")
  }
}

parameters = read.csv("model_parameters.csv",
                      colClasses = c("numeric",
                                     "numeric",
                                     "numeric",
                                     "character",
                                     "character",
                                     "numeric",
                                     "character"))[i,]

alpha = parameters["alpha"]
alpha2 = parameters["alpha2"]
cost = parameters["cost"]
alternatives = parameters["alternatives"]
model_type = parameters["model"]
story.number = parameters["story.number"][[1]]
background_knowledge = parameters["background_knowledge"]

get_s2_options = function(alpha, cost, story.number,
                          background_knowledge, alternatives,
                          alpha2) {
  return(paste("{ costPerWord: ", cost,
               ", s2_costPerWord: ", cost,
               ", alternatives: '", alternatives, "'",
               ", s2_alternatives: 'yes/no'",
               ", lambda1: ", alpha,
               ", lambda2: ", alpha2,
               ", QUD: extractGraph",
               ", s2_QUD: extractGraph",
               ", worldFn: lk", story.number,
               ", worldLabel: 'lk", story.number, "'",
               ", background_knowledge: '", background_knowledge, "'",
               "}", sep=""))
}

run_model = function(explanation, actual.world) {
  
  model_var = paste(
    model_type, "(",
    "'", actual_utterance=explanation, "'",
    ", ", actual_world = str2world(actual.world),
    ", ", options=get_s2_options(alpha, cost, story.number,
                                 background_knowledge, alternatives,
                                 alpha2),
    ")", sep="")
  
  program_file = "lk-flat.wppl"
  
  rs = webppl(
    model_var = model_var,
    program_file = program_file,
    inference_opts = list(method="enumerate")
  )
  return(sum((rs %>% filter(support==explanation))$prob))
}

print.graph = function(g) {
  return(names(graphs)[[which(graphs==g)]])
}

my.story.number = story.number
df = read.csv("alternative_causal_structures.csv",
              colClasses = c("numeric", "character", "character")) %>%
  filter(story.number==my.story.number) %>%
  mutate(model = mapply(run_model, explanation, actual.world))
df = df %>% mutate(
  alpha = alpha[[1]],
  alpha2 = alpha2[[1]],
  cost = cost[[1]],
  alternatives = alternatives[[1]],
  model_type = model_type[[1]],
  background_knowledge = background_knowledge[[1]]
)

filename = paste("results/rs_", time, "_",
                 sub("/", "", paste(parameters, collapse="_")), ".csv", sep="")

write.csv(df, filename, row.names = F)