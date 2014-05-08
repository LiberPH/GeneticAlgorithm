#!/usr/bin/env Rscript

# ...

argv <- commandArgs(T);

# error checking...

if(argv[1]==1){
    out <- runif(1, 0, 1)#k_prod_Aa
}
if(argv[1]==2){
    out <- runif(1, 0, 1)#k_prod_Aa
}
if(argv[1]==3){
    out <- runif(1, 0, 1)#k_prod_Aa
}
if(argv[1]==4){
    out <- runif(1, 0.118612706, 0.711676235)#k_prod_Aa
}
if(argv[1]==5){
    out <- runif(1, 60, 60000)#k_prod_Aa
}
if(argv[1]==6){
    out <- runif(1, 0, 20)#k_prod_Aa
}
if(argv[1]==7){
    out <- runif(1, 0, 1)#k_prod_Aa
}


write.table(out, file = "param.txt",row.names=FALSE,col.names=FALSE)
sink()
cat(out)
