#!/usr/bin/env Rscript

# ...

argv <- commandArgs(T);

# error checking...
#x <- read.table("recomb_us.txt",sep = "",header=FALSE);
x <- read.table(argv[3],sep="",header=FALSE)
a <- as.numeric(argv[1])
#write.table(a, file = "a.txt",row.names=FALSE,col.names=FALSE)
b <- as.numeric(argv[2])
#write.table(b, file = "b.txt",row.names=FALSE,col.names=FALSE)
#a <- 2
#b <- 4
a <- a+1
b <- b+1

x1 <-as.vector(x[1,])
x2 <-as.vector(x[2,]) 

son <- x1
for(i in a:b){
w <- as.numeric(x1[i])
z <- as.numeric(x2[i])
	if(z<=w){
		son[i] <- runif(1,z,w)
	}
	if(z>w){
		son[i] <- runif(1,w,z)
	}
}


write.table(son, file = "son.txt",row.names=FALSE,col.names=FALSE)

