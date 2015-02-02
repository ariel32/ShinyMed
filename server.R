library(shiny)
library(datasets)
library(RSQLite)
library(ggplot2)

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
                                         ,selectInput("csname", "Аптека:", sort(dt$CSname))
                                         ,textOutput("cs.address")
                                         ,hr()
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
                                         ,selectInput("c2.medicine", "",
                                                     c("Детралекс" = "detraleks",
                                                       "Престанс 5/5" = "prestance55",
                                                       "Престанс 5/10" = "prestance510",
                                                       "Престанс 10/5" = "prestance105",
                                                       "Престанс 10/10" = "prestance1010",
                                                       "Кораксан 5" = "koraksan5",
                                                       "Кораксан 7" = "koraksan7"))
                                         ,textOutput("q2")
                            ),
                            mainPanel(h3("Main Panel")
                                      , dataTableOutput("table")
                            )
                   ),
                   ##### TAB3
                   tabPanel("Component 3"
                            sidebarPanel(h3("Sidebar Panel")
                            ),
                            mainPanel(h3("Main Panel")
                                      plotOutput("c3.plot")
                            )
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
    a$time <- as.POSIXct(a$time, origin = "1970-01-01")
    p <- ggplot(a, aes(x = time, y = quantity)) + geom_point()
    p <- p + stat_smooth(method = "loess", formula = y ~ x, size = 1)
    print(p)
  })

  
  output$cs.address <- renderText({ dt$address[which(dt$CSname == input$csname)] })
  
  
  
  
  
  ##### обрабатываем данные о ЛС
  query2 = reactive({ sprintf(
    "SELECT chemshop.CSname, data.quantity
    FROM chemshop, data
    WHERE chemshop.CSname = data.CSname AND data.medicine ='%s'",input$c2.medicine) })
  output$q2 <- renderText({ query2() })
  
  output$table <- renderDataTable({
    dbquery2 <- query2()
    a2 = dbGetQuery(conn = db, dbquery2)
    a2$quantity <- as.numeric(as.character(a2$quantity))
    a2$quantity[which(is.na(a2$quantity))] = 0
    
    d = data.frame(); c2.cs = vector()
    for(x in unique(a2$CSname)) {
      c2.cs = append(c2.cs, x)
      d = rbind(d, summary(a2$quantity[which(a2$CSname == x)]))
   }
      tt <- cbind(c2.cs,d)
      names(tt) <- c("Аптека", "Мин", "1й кв", "Среднее", "Медиана", "3й кв", "Макс")
      print(tt)
  }, options=list(pageLength=10))
  
  
  
  
  
})