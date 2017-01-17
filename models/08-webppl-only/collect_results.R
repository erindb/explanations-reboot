df = do.call(rbind, lapply(list.files("results/"), function(file) {
  read.csv(paste("results/", file, sep=""))
}))
write.csv(df, "results.csv", row.names=F)

