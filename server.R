library(shiny)
library(datasets)
Logged = T;
PASSWORD <- data.frame(Brukernavn = "capsula",
                       Passord = "fcb7a22d61fabc0b820fca872b5e7a5c")

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
  source("www/login.R",  local = TRUE)
  
  observe({
    if (USER$Logged == TRUE) {
      output$MainUI <- renderUI({
        ##### START GUI
        navbarPage("Capsulitica",
                   
                   ##### TAB1
                   tabPanel("Component 1",
                            sidebarPanel(h3("Sidebar Panel")
                                         ,radioButtons("plotType", "Plot type", c("Scatter"="p", "Line"="l"))
                                         ,textInput("caption", "Caption:", "Название графика")
                            ),
                            mainPanel(h3("Main Panel")
                                      #, textOutput("text1")
                                      , plotOutput("plot1")
                            )
                   ),
                   
                   ##### TAB2
                   tabPanel("Component 2",
                            sidebarPanel(h3("Sidebar Panel")
                            ),
                            mainPanel(h3("Main Panel")
                                      , dataTableOutput("table")
                            )
                   ),
                   ##### TAB3
                   tabPanel("Component 3")
        )
      })
      ##### END GUI
    }
  })
  ##### END OBSERVE
  #output$text1 <- renderText({ input$caption })
  output$plot1 <- renderPlot({ plot(cars, type=input$plotType, main = input$caption) })
  output$table <- renderDataTable({ cars }, options=list(pageLength=10))
  

})