#!/usr/bin/env Rscript

# ...
####################################################################
#Recieves the number of parameters to guess and the range of them
#(if available)
#
#Fixing values...
#x1 <- runif(1, 1, 100000)
#x2 <- runif(1, 1, 100000)
#x3 <- runif(1, 0, 10)
#x4 <- runif(1, 0, 1000)
#x5 <- runif(1, 0, 1000)
#x6 <- runif(1, 1, 1000)
###################################################################

# error checking...

x1 <- runif(1, 0, 1)
x2 <- runif(1, 0, 1)
x3 <- runif(1, 0, 1)
x4 <- runif(1, 0.118612706, 0.711676235)
x5 <- runif(1, 60, 60000)
x6 <- runif(1, 0, 20)
x7 <- runif(1, 0, 1)

out <- c(x1,x2,x3,x4,x5,x6,x7)

cat(out)
sink()
