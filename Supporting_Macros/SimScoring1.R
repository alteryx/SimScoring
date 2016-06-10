## DO NOT MODIFY: Auto Inserted by AlteryxRhelper ----
library(AlteryxSim)
config <- list(
  displaySeed = checkboxInput('%Question.displaySeed%' , FALSE),
  isGLM = checkboxInput('%Question.isGLM%' , FALSE),
  numRecords = numericInput('%Question.numRecords%' , 256000),
  per.iter = numericInput('%Question.per.iter%' , 1),
  results.name = textInput('%Question.results.name%' , 'Score'),
  seed = numericInput('%Question.seed%' , 50)
)

chunkSize <- config$numRecords
isGLM <- config$isGLM
mult <- config$per.iter
seed <- config$seed

## Inputs ----

model <- unserializeObject(as.character(read.Alteryx("model")$Object[1]))
totalCount <- as.integer(unlist(read.Alteryx("totalCountSim", mode="list"))[1])
validation <- if (!isGLM) read.Alteryx("validation") else NULL

scoreProcess(model, isGLM, mult, totalCount, validation, seed, chunkSize, "__results__")
