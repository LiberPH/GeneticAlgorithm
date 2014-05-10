#!/usr/bin/env Rscript

# ...

argv <- commandArgs(T); #Passing arguments (Simulations' results)

# error checking...

x <- read.table(argv[1],sep = ""); #Reading simulation result a)


x <- x[,2];
#x
y <- read.table(argv[2],sep = ""); #Reading simulation result b)
y <- y[,2];
diff <- dist(rbind(x, y), method = "canberra")  #Calculating Canberra's distance between two simulations' results
sink("output.txt")
cat(diff) #Send diff to bash
sink()


