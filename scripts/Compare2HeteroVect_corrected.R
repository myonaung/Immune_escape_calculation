Compare2HeteroVect = function(a,b){ 
  
  score = rep(0,ncol(a))
  for (i in 1:ncol(a)){
    anuc = a[1,i]
    bnuc = b[1,i]
    if (anuc == bnuc){score[i] = 0}
    else if (anuc != bnuc){score[i] = 1}
  }
  return(score)
}
