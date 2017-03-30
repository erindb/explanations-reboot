source("~/Settings/startup.R")

my_dodge <- function(width = NULL, preserve = c("total", "single")) {
  ggproto(NULL, MyDodge,
          width = width,
          preserve = match.arg(preserve)
  )
}

# Detect and prevent collisions.
# Powers dodging, stacking and filling.
my_collide <- function(data, width = NULL, name, strategy, ..., check.width = TRUE, reverse = FALSE) {
  # Determine width
  if (!is.null(width)) {
    # Width set manually
    if (!(all(c("xmin", "xmax") %in% names(data)))) {
      data$xmin <- data$x - width / 2
      data$xmax <- data$x + width / 2
    }
  } else {
    if (!(all(c("xmin", "xmax") %in% names(data)))) {
      data$xmin <- data$x
      data$xmax <- data$x
    }
    
    # Width determined from data, must be floating point constant
    widths <- unique(data$xmax - data$xmin)
    widths <- widths[!is.na(widths)]
    
    #   # Suppress warning message since it's not reliable
    #     if (!zero_range(range(widths))) {
    #       warning(name, " requires constant width: output may be incorrect",
    #         call. = FALSE)
    #     }
    width <- widths[1]
  }
  
  # Reorder by x position, then on group. The default stacking order reverses
  # the group in order to match the legend order.
  if (reverse) {
    data <- data[order(data$xmin, data$group), ]
  } else {
    data <- data[order(data$xmin, -data$group), ]
  }
  
  
  # Check for overlap
  intervals <- as.numeric(t(unique(data[c("xmin", "xmax")])))
  intervals <- intervals[!is.na(intervals)]
  
  if (length(unique(intervals)) > 1 & any(diff(scale(intervals)) < -1e-6)) {
    warning(name, " requires non-overlapping x intervals", call. = FALSE)
    # This is where the algorithm from [L. Wilkinson. Dot plots.
    # The American Statistician, 1999.] should be used
  }
  
  if (!is.null(data$ymax)) {
    plyr::ddply(data, "xmin", strategy, ..., width = width)
  } else if (!is.null(data$y)) {
    data$ymax <- data$y
    data <- plyr::ddply(data, "xmin", strategy, ..., width = width)
    data$y <- data$ymax
    data
  } else {
    stop("Neither y nor ymax defined")
  }
}

MyDodge <- ggproto(
  "MyDodge",
  Position,
  required_aes = "x",
  width = NULL,
  preserve = "total",
  setup_params = function(self, data) {
    if (is.null(data$xmin) && is.null(data$xmax) && is.null(self$width)) {
      warning("Width not defined. Set with `position_dodge(width = ?)`",
              call. = FALSE)
    }
    
    if (identical(self$preserve, "total")) {
      n <- NULL
    } else {
      n <- max(table(data$xmin))
    }
    
    list(
      width = self$width,
      n = n
    )
  },
  
  compute_panel = function(data, params, scales) {
    my_collide(
      data,
      params$width,
      name = "my_dodge",
      strategy = my_dodge_strategy,
      n = params$n,
      check.width = FALSE
    )
  }
)

# Dodge overlapping interval.
# Assumes that each set has the same horizontal position.
my_dodge_strategy <- function(df, width, n = NULL) {
  if (is.null(n)) {
    n <- length(unique(df$group))
  }
  
  if (n == 1)
    return(df)
  
  if (!all(c("xmin", "xmax") %in% names(df))) {
    df$xmin <- df$x
    df$xmax <- df$x
  }
  
  d_width <- max(df$xmax - df$xmin)
  
  # Have a new group index from 1 to number of groups.
  # This might be needed if the group numbers in this set don't include all of 1:n
  groupidx <- match(df$group, sort(unique(df$group)))
  
  # width is 1 and d_width is 1
  # print(df$x) # do not change df$x. that's just the value of A
  grplen = length(groupidx)
  n = n/2
  groupidx = rep(groupidx[(grplen-n+1) : grplen], 2)

  # Find the center for each group, then use that to calculate xmin and xmax
  df$x <- df$x + width * ((groupidx - 0.5) / n - .5)
  df$xmin <- df$x - d_width / n / 2
  df$xmax <- df$x + d_width / n / 2
  
  df
}

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
  geom_tile(position=my_dodge()) +
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