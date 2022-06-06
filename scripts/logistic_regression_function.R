
logistic_regression <- function(file_csv) {
  date = paste0("_", Sys.Date())
  data_lmer = read.csv(file_csv)
  data_lmer = data_lmer[-c(1)]
  
  value = ncol(data_lmer)
  age = value -1
  end = value -2
  predictors = names(data_lmer[c(2:end)])
  
  #log.model <- glm(data_lmer[,1] ~ data_lmer[,17] + data_lmer[,value] + data_lmer[,age],  family=binomial(link='logit'))
  #test = summary(log.model)
  #test
  
  model_out = list()
  for (i in 2:end){
    out = summary(glm(data_lmer[,1] ~ data_lmer[,i] + data_lmer[,value], family = binomial(link='logit')))
    model_out[[i]] <- out
  }
  
  #significance
  p_value_predictor = do.call('rbind', 
                              lapply(seq_len(length(model_out)), 
                                     function(i) coefficients(model_out[[i]])[2,4]))
  p_value_predictor = as.data.frame(p_value_predictor)
  row.names(p_value_predictor) = colnames(data_lmer[c(2:end)])
  p_value_predictor <- tibble::rownames_to_column(p_value_predictor, "snps")
  names(p_value_predictor)[2] = "p-value"
  
  #estimate
  effect_predictor = do.call('rbind', 
                             lapply(seq_len(length(model_out)), 
                                    function(i) coefficients(model_out[[i]])[2,1]))
  effect_predictor = as.data.frame(effect_predictor)
  row.names(effect_predictor) = colnames(data_lmer[c(2:end)])
  effect_predictor <- tibble::rownames_to_column(effect_predictor, "snps")
  names(effect_predictor)[2] = "effect estimate"
  
  
  #error
  error_predictor = do.call('rbind', 
                            lapply(seq_len(length(model_out)), 
                                   function(i) coefficients(model_out[[i]])[2,2]))
  error_predictor = as.data.frame(error_predictor)
  row.names(error_predictor) = colnames(data_lmer[c(2:end)])
  error_predictor <- tibble::rownames_to_column(error_predictor, "snps")
  names(error_predictor)[2] = "std. error"
  
  results_intermediate = merge(effect_predictor,p_value_predictor, by ="snps")
  results_final = merge(results_intermediate,error_predictor, by ="snps")
  outname =  paste0(out_path,antigen, date, "_logistic_regression.csv")
  write.csv(results_final,outname, row.names = F)
  
}
