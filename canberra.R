#!/usr/bin/env Rscript

# ...

argv <- commandArgs(T);

# error checking...

x <- read.table(argv[1],sep = "");


x <- x[,2];
#x
y <- read.table(argv[2],sep = "");
y <- y[,2];
diff <- dist(rbind(x, y), method = "canberra")  #Calculando distancia de canberra entre dos dinámicas
sink("output.txt")
cat(diff)
sink()


