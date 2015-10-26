
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(caret)
library(dplyr)
library(randomForest)
library(ggplot2)

shinyServer( function(input, output) {
        
        
        modelOutput<-reactive({
               
                
                progress <- shiny::Progress$new()
                # Make sure it closes when we exit this reactive, even if there's an error
                on.exit(progress$close())
                
                progress$set(message = "Reading data", value = 0)
                rawmotionDat <- read.csv("data/pml-training.csv")
                
                motionDat<- rawmotionDat %>% 
                        select(one_of(c("roll_belt","pitch_belt","yaw_belt",
                                        "total_accel_belt","gyros_belt_x","gyros_belt_y","gyros_belt_z",
                                        "accel_belt_x","accel_belt_y","accel_belt_z","magnet_belt_x",
                                        "magnet_belt_y","magnet_belt_z","roll_arm","pitch_arm","yaw_arm",
                                        "total_accel_arm","gyros_arm_x","gyros_arm_y","gyros_arm_z",
                                        "accel_arm_x","accel_arm_y","accel_arm_z","magnet_arm_x",
                                        "magnet_arm_y","magnet_arm_z","roll_dumbbell","pitch_dumbbell",
                                        "yaw_dumbbell","total_accel_dumbbell","gyros_dumbbell_x",
                                        "gyros_dumbbell_y","gyros_dumbbell_z","accel_dumbbell_x",
                                        "accel_dumbbell_y","accel_dumbbell_z","magnet_dumbbell_x",
                                        "magnet_dumbbell_y","magnet_dumbbell_z","roll_forearm","pitch_forearm",
                                        "yaw_forearm","gyros_forearm_x","gyros_forearm_y","gyros_forearm_z",
                                        "accel_forearm_x","accel_forearm_y","accel_forearm_z",
                                        "magnet_forearm_x","magnet_forearm_y","magnet_forearm_z","classe")))
                
                progress$set(message = "Building Model", value = 0)
                
                inTrain <- createDataPartition(y=motionDat$classe,p=input$holdoutSample,list=FALSE)
                training <- motionDat[inTrain,]
                nottrain <- motionDat[-inTrain,]
                
              
                M<-abs(cor(training [,1:51]))
                diag(M)<-0
                newM<-which(M > input$corrThresh, arr.ind=T) #get the variables whose correlation is > correlation threshold
                important_vars<-as.data.frame(rownames(newM))%>%distinct()
                important_vars_n<-c(as.character(important_vars[,1]),"classe")
                
                training<-select(training,one_of(important_vars_n))
                
                nottrain <- select(nottrain,one_of(important_vars_n))
                
                #in the above example, we held out 60% for the training, thus notrain is 40%, since the 
                #recommendation for sizes of validation and test set data is 20% of the original, I will 
                #split this part in half
                
                v_and_t<- createDataPartition(y=nottrain$classe,p=1-input$holdoutSample,list=FALSE)
                validation <- nottrain[v_and_t,]
                pretest <- nottrain[-v_and_t,]
                
                set.seed(1785) #the year UGA was founded
                
                progress$set(message = "Calcuating Random Forest ... Please stand by; it takes 4 ~ 5 minutes", value = 0)
                
                modFitRF <- randomForest(classe ~ ., method="rf", data=training,prox=TRUE,importance=TRUE)
                #much better accuracy, but let's try with validation
  
                predRF <- predict(modFitRF,newdata=validation)
                
                cfRM<-confusionMatrix(validation$classe,predRF)
                
                                
        })
        
        modelPlot<-reactive({
                cfPlotRM <- as.data.frame(as.table(cfRM$table))
                plot2 <- ggplot(cfPlotRM)
                plot2 + geom_tile(aes(x=Prediction, y=Reference, fill=Freq)) + 
                        scale_x_discrete(name="Actual Class") + 
                        scale_y_discrete(name="Predicted Class") + 
                        scale_fill_gradient(breaks=seq(from=-0, to=1, by=.2)) + 
                        labs(fill="Normalized\nFrequency") +
                        ggtitle("Confusion Matrix Plot for Random Forest Model")
        })
        
        output$holdoutSample<-renderPrint({input$holdoutSample})
        output$corrThresh <-renderPrint({input$corrThresh})
        output$motionDat <- renderPrint(print(modelOutput()))
        output$modelPlot <- renderPlot({
                print(modelPlot())
        })
        
        
})
