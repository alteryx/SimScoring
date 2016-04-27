## DO NOT MODIFY: Auto Inserted by AlteryxRhelper ----
library(AlteryxRhelper)
config <- list(
  displaySeed = checkboxInput('%Question.displaySeed%' , FALSE),
  isGLM = checkboxInput('%Question.isGLM%' , FALSE),
  numRecords = numericInput('%Question.numRecords%' , 256000),
  per.iter = numericInput('%Question.per.iter%' , 1),
  results.name = textInput('%Question.results.name%' , 'Score'),
  seed = numericInput('%Question.seed%' , 50)
)
# options(alteryx.wd = '%Engine.WorkflowDirectory%')
# options(alteryx.debug = config$debug)

## Configuration ----

#scoreName <- '%Question.results.name%'
# chunkSize <- as.integer('%Question.numRecords%')
# if(is.na(chunkSize)) {
#   chunkSize <- 256000
# }
#isGLM <- '%Question.isGLM%'=="True"
#mult <- as.integer(unlist(read.Alteryx("mult", mode="list"))[1])
#seed <- as.integer(unlist(read.Alteryx("seed", mode="list"))[1])
#tarVarName <- '%Question.targetVariable%'
# validation <- NULL
# if(!isGLM) {
#   validation <- read.Alteryx("validation")
# }


scoreName <- config$results.name
chunkSize <- config$numRecords
isGLM <- config$isGLM
mult <- config$per.iter
seed <- config$seed

## Inputs ----

model <- unserializeObject(as.character(read.Alteryx("model")$Object[1]))
totalCount <- as.integer(unlist(read.Alteryx("totalCountSim", mode="list"))[1])
validation <- if (!isGLM) read.Alteryx("validation") else NULL

print(Sys.time())

##----
#' Repurpose {stats} package 'simulate' function to work on new data
#'
#' @param object model object to score from
#' @param nsim number of draws per record
#' @param new_values new data to score against model
#' @return function taking new data and simulating scores
#' @export
simulateGLM <- function(object, nsim) {
  function(new_data) {
    new_preds <- predict(object, new_data)
    object$fitted.values <- new_preds
    simulate(object = object, nsim = nsim, seed = NULL)
  }
}

#' Map reduce code to help with processing of chunks
#'
#' @param nameInput if data is coming from Alteryx, name of the input data is coming from
#' @param chunkSize maximal size of chunk
#' @param totalSize total size of data
#' @param data dataframe outside of Alterx, not dataframe if inside Alteryx
#' @return function taking two function arguments - a map function and a reduce function and applying them as expected
#' @export
#' @examples
#'    mapReduce(NULL, 15, 100, data.frame(x = 1:100))(sum, function(x) {sum(unlist(x))})
#'    mapReduce(NULL, 15, 100, data.frame(x = 1:100))(function(x) {sum(x^2)}, function(x) {sum(unlist(x))})
mapReduce <- function(nameInput, chunkSize, totalSize, data) {
  function(map, reduce) {
    chunkCount <- ceiling(totalSize/chunkSize)
    getData <- function(chunkNumber) {
      if (class(data) != "data.frame") {
        if(chunkNumber == 1) {
          read.Alteryx.First(nameInput, chunkSize)
        } else {
          read.Alteryx.Next(nameInput)
        }
      } else {
        data[((chunkNumber-1)*chunkSize+1):(min(totalSize, chunkSize*chunkNumber)),]
      }
    }
    processChunk <- function(chunkNumber) {
      map(getData(chunkNumber))
    }
    if(!is.null(reduce)) {
      mappings <- lapply(1:chunkCount, processChunk)
      reduce(mappings)
    } else {
      lapply(1:chunkCount, processChunk)
    }
  }
}

#' Code to execute core of simulation scoring code 
#' 
#' @param model model object to score from
#' @param isGLM boolean predicting whether object will be glm/lm class
#' @param number of draws from error distribution for each record
#' @param totalCOuntSim total number of records to be scored
#' @param validation validation data incoming
#' @param seed random seed
#' @param sim simulation data to score
#' @param scoreName name to give to scored variable
#' @param chunkSize maximal chunk size for scored data
#' @return nothing - function writes out score df to Alteryx
scoreProcess <- function(model, isGLM, mult, totalCountSim, validation, seed, chunkSize, scoreName) {
  scoreErrorCheck(model, isGLM)
  set.seed(seed)
  tarVarName <- getTarVarName(model)
  mapfxn <- function(x) {
    if(isGLM) {
      simData <- unlist(simulateGLM(model, mult)(x))
    } else {
      predVal <- predict(model, validation)
			if(any(names(predVal)=="Yes")) {
				predVal <- predVal$Yes
			}
			if(any(names(predVal)=="YES")) {
				predVal <- predVal$YES
			}
			if(any(names(predVal)=="yes")) {
				predVal <- predVal$yes
			}
			predVal <- as.vector(predVal)
      actualVal <- convertTo01(as.vector(validation[,tarVarName]))
      errors <- actualVal - predVal
      simData <- unlist(simulateNonGLM(model, mult, errors) (x))
    }
    df <- data.frame(score = simData)
    names(df) <- scoreName
    write.Alteryx(df, 1)
  }
  mapReduce("sim", chunkSize, totalCountSim, NULL) (mapfxn, NULL)
}


#' Error check to ensure model class matches "isGLM"
#' 
#' @param model model to check
#' @param isGLM boolean to compare
#' @return no return - just throws error if mismatch
scoreErrorCheck <- function(model, isGLM) {
  glmClass <- any(class(model)=="glm") || any(class(model)=="lm")	
  if(isGLM && !glmClass) {
    stop("Model is not glm or lm. Connect a validation dataset.")
  } 
  if(!isGLM && glmClass) {
    stop("Model is glm or lm. Disconnect validation dataset.")
  }
}

#' Extract target variable name from model object
#' 
#' @param model model from which to extract target variable
#' @return string - name of model's target variable
#' @export
getTarVarName<- function(model){
  as.character(model$terms[[2]])
}

#' Simulation function assuming homoscedasticity
#'
#' @param object model object to score from
#' @param nsim number of draws per record
#' @param new_values new data to score against model
#' @return function taking new data and simulating scores
#' @export
simulateNonGLM <- function(object, nsim, errorVec) {
  function(newdata) {
		fullErrors <- sample(errorVec, length(newdata)*nsim, replace = TRUE)
		newPreds <- as.vector(predict(object, newdata = newdata))
    scores <- rep(newPreds, nsim) + fullErrors
    unlist(lapply(scores, FUN = getScore))
  }
}

#' Helper function for simulateNonGLM for scores < 0 or > 1
#' 
#' @param x value to fix score of
#' @return proper score
getScore <- function(x) {
  median(c(0,x,1))
}

#' Generic method for converting vector to 0/1
#' 
#' @param vec vector to convert
#' @return vector of 0/1
#' @export
convertTo01 <- function(vec) {
  UseMethod('convertTo01')
}

#' convert character of Yes/No vector to 0/1
#' 
#' @param vec vector to convert
#' @return vector of 0/1
#' @import stringr
#' @export
convertTo01.chr <- function(vec) {
  vec <- tolower(str_trim(vec))
  if(!any(vec == "yes") || !any(vec =="no")) {
    stop("must be yes/no")
  }
  ifelse(vec=="yes", 1, 0)
}



#' convert character of Yes/No vector to 0/1
#' 
#' @param vec vector to convert
#' @return vector of 0/1
#' @import stringr
#' @export
convertTo01.character <- function(vec) {
  vec <- tolower(str_trim(vec))
  if(!any(vec == "yes") || !any(vec =="no")) {
    stop("must be yes/no")
  }
  ifelse(vec=="yes", 1, 0)
}

#' Convert default vector to 0/1
#' 
#' @param vec vector to convert
#' @return vector of 0/1
#' @export
convertTo01.default <- function(vec) {
  vec
}




scoreProcess(model, isGLM, mult, totalCount, validation, seed, chunkSize, scoreName)
