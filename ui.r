# Define UI for application
ui <- fluidPage(
  
  # Application title
  titlePanel(title = h3("Australia Bushfire Seasons for NSW, VIC & QLD: 2002-2020", align="center")),
  br(),   br(),
  sidebarLayout(
    sidebarPanel(
      #------------------------------------------------------------------
      # Add radio button to choice for states
      radioButtons("data_input", 
                   label = "Select Data: ",
                   choices = list("New South Wales" = 'NSW', 
                                  "Victoria" = 'VIC', 
                                  "Queensland" = 'QLD'),
                   selected = 'NSW'),
      br(),   br(),
      #------------------------------------------------------------------
      # Add Variable for Year Selection
      sliderInput("year_range", 
                  "Select Year Range : ", 
                  min=2002, max=2020, 
                  value=c(2002, 2020), 
                  step=1
      ),
      
      br(),   br()
      #------------------------------------------------------------------
      # Change background color for body
      #tags$style("body{background-color:lightyellow; color:brown}")
    ),
    
    mainPanel(
      #------------------------------------------------------------------
      # Create tab panes
      tabsetPanel(type="tab",
                  tabPanel("Summary",verbatimTextOutput("summary_data")),
                  tabPanel("Data Table", tableOutput("data_table")),
                  tabPanel("Charts", plotOutput("charts"))
      )
      
      #------------------------------------------------------------------
    )
  )
  
)