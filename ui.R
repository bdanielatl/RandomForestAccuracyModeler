
# This is the user-interface definition of a Shiny web application.
# This application will model the accuarcy of a random forest that analyzes and classifies
# dumbell lift errors (A-E).
#

library(shiny)

shinyUI(

        fluidPage(
                # Application title
                titlePanel("Random Forest Accuracy Modeler"),
                
                sidebarLayout(
                        # Sidebar with a slider and selection inputs
                        #
                        sidebarPanel(
                                h3("Model Threshold Inputs "),
                                sliderInput("holdoutSample",
                                            "Training Holdout Sample Size:",
                                            min = .1,  max = .99, value = .5),
                                sliderInput("corrThresh",
                                            "Correlation Threshold:",
                                            min = .1,  max = .9,  value = .5),
                                submitButton('Run Model')
                                
                                
                        ),
                        
                        # Show Word Cloud
                        mainPanel(
                                h3('Description'),
                          p('This application demonstrates how different samples sizes and correlation
                            thresholds can affect model accuracy.  The application uses the Random Forest 
                            model to classify dumbell lifting errors given a training and validation set.'
                            ),
                          h3('Instructions'),
                          p('Adjust the hould out sample size and the correlation threshold and click the Go button.
                            The model will recalculate and show its acheived accuracy. Note that random forests can
                            take a little while to build, please be patient until the results change in this panel.'),
                     
                         h3('Results'),
                         h4('Hold out sample'),
                         verbatimTextOutput("holdoutSample"),
                         h4('Correlation Threshold'),
                         verbatimTextOutput("corrThresh"),
                         h4('Results from the Confusion Matrix'),
                         verbatimTextOutput('motionDat'),       
                         plotOutput('modelPlot')
                        
                         
                        )
                )
        )
)

