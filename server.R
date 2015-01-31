library(shiny)
library(datasets)
library("RSQLite")

Logged = T;
PASSWORD <- data.frame(Brukernavn = "capsula",
                       Passord = "fcb7a22d61fabc0b820fca872b5e7a5c")

db = dbConnect(SQLite(), dbname="db.sqlite")
dbReadTable(db, "chemshop") -> dt
#dbReadTable(db, "data") -> cst

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
  source("www/login.R",  local = TRUE)
  
  observe({
    if (USER$Logged == TRUE) {
      output$MainUI <- renderUI({
        ##### START GUI
        navbarPage("Capsulitica",
                   
                   ##### TAB1
                   tabPanel("ЛС",
                            sidebarPanel(h3("Sidebar Panel")
                                         ,radioButtons("plotType", "Plot type", c("Scatter"="p", "Line"="l"))
                                         ,selectInput("csname", "Аптека:", sort(dt$CSname))
                                         ,textOutput("cs.address")
                                         ,selectInput("medicine", "",
                                                      c("Детралекс" = "detraleks",
                                                        "Престанс 5/5" = "prestance55",
                                                        "Престанс 5/10" = "prestance510",
                                                        "Престанс 10/5" = "prestance105",
                                                        "Престанс 10/10" = "prestance1010",
                                                        "Кораксан 5" = "koraksan5",
                                                        "Кораксан 7" = "koraksan7"))
                                         ,textOutput("sqlite.debug")
                                         
                            ),
                            mainPanel(h3("Main Panel")
                                      , plotOutput("plot1")
                            )
                   ),
                   
                   ##### TAB2
                   tabPanel("Аптеки",
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
  
  
  query = reactive({
    paste("SELECT time, quantity FROM data WHERE
                medicine = '",input$medicine,"' AND CSname = '", input$csname ,"'"
          ,sep = "")
  })
  output$sqlite.debug <- reactiveText ({ query })
  output$plot1 <- renderPlot({
    dbquery <- query()
    a = dbGetQuery(conn = db, dbquery)
    print(plot(as.POSIXct(a$time, origin = "1970-01-01"), a$quantity, type = input$plotType))
  })

#   a = dbGetQuery(conn = db, query)
#   plot(as.POSIXct(a$time, origin = "1970-01-01"), a$quantity, type = input$plotType)
  
  
  output$cs.address <- renderText({ dt$address[which(dt$CSname == input$csname)] })
  
  
  
  
  
#   new.t = dbGetQuery(conn = db,
#                      "SELECT chemshop.CSname, AVG(data.quantity)
#                      FROM chemshop, data
#                      WHERE chemshop.CSname = data.CSname AND data.medicine ='detraleks'
#                      GROUP BY chemshop.CSname")
#   output$table <- renderDataTable({ new.t }, options=list(pageLength=10))
  
  
  
  
  
})