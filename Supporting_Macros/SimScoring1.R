## DO NOT MODIFY: Auto Inserted by AlteryxRhelper ----
library(AlteryxRhelper)
library(AlteryxSim)
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

scoreProcess(model, isGLM, mult, totalCount, validation, seed, chunkSize, scoreName)
