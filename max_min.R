#!/usr/bin/env Rscript

argv <- commandArgs(T);

# error checking...
#x <- as.vector(read.table("/home/libertad/Documentos/GA/all_diff.txt",sep=""));
x <- as.vector(read.table(argv[1],sep = ""));
#n <- argv[2]


maxim <- max(x)
minum <- min(x)

a <-  maxim == minum
which( x == min(x) )
if(a) {
      out <- 0
    } else {
      out <- which.min(x)
       y <- t(order(x))
      w <- y-1
      write.table(w, file = "order.txt",row.names=FALSE,col.names=FALSE)
      write.table(sort(x), file = "ordered_guys_values.txt",row.names=FALSE,col.names=FALSE)
    }


cat(out)
sink()



#X <- c(11:19,19)

#n <- length(unique(X))
#which(X == sort(unique(X),partial=n-1)[n-1])
