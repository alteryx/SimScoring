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


if (AlteryxFullUpdate) {
  meta.data <- read.AlteryxMetaInfo("sim")
  # Write out the metadata for the "pass-through" data
  meta.data$Name <- as.character(meta.data$Name)
  meta.data$Type <- as.character(meta.data$Type)
  meta.data$Source <- as.character(meta.data$Source)
  for (i in 1:nrow(meta.data))
    write.AlteryxAddFieldMetaInfo(nOutput = 1, name = meta.data$Name[i], fieldType = meta.data$Type[i], size = meta.data$Size[i], source = meta.data$Source[i])
  # Write out the metadata for the score field
  score.field <- "asdfasdfresultsasdfasdf"
  write.AlteryxAddFieldMetaInfo(nOutput = 1, name = score.field, fieldType = "Double", size = 8, source = "R-DATA:")
} else {
  chunkSize <- config$numRecords
  valCount <- unlist(as.numeric(read.Alteryx("valCount")))[1]
  isGLM <- valCount == 0
  mult <- config$per.iter
  seed <- config$seed
  
  ## Inputs ----
  
  
  model <- unserializeObject(as.character(read.Alteryx("model")$Object[1]))
  totalCount <- as.integer(unlist(read.Alteryx("totalCountSim", mode="list"))[1])
  validation <- if (!isGLM) read.Alteryx("validation") else NULL
  
  
  scoreProcess(model, isGLM, mult, totalCount, validation, seed, chunkSize)
} 