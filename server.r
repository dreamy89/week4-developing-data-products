
#Specify and Load Libraries
list.of.packages <- c(
  "shiny",
  "ggplot2",
  "dplyr"
)

###Install/load required packages
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

#Set seed
set.seed(123)

#Read data
bushfire_nsw <- read.csv("http://globalfiredata.org/pages/wp-content/uploads/2020/01/Table_MODIS_fire_counts_2002_2019_NSW_per_fire_year.csv")
bushfire_vic <- read.csv("http://globalfiredata.org/pages/wp-content/uploads/2020/01/Table_MODIS_fire_counts_2002_2019_Victoria_per_fire_year.csv")
bushfire_qld <- read.csv("http://globalfiredata.org/pages/wp-content/uploads/2020/01/Table_MODIS_fire_counts_2002_2019_Queensland_per_fire_year.csv")

#Transform data
  
  bushfire_nsw$state <- "NSW"
  bushfire_vic$state <- "VIC"
  bushfire_qld$state <- "QLD"
  
  bushfire_all <- rbind(bushfire_nsw, bushfire_qld, bushfire_vic)

for (i in 1:(length(names(bushfire_all))-2)){
  temp1 <- as.data.frame(bushfire_all$DOY)
  names(temp1)[1] <- "day_of_year"
  temp1$state <- bushfire_all$state
  temp1$fire_count <- bushfire_all[,i+1]
    temp1$date <- as.Date(temp1$day_of_year, 
                          origin = paste0(2001+i, "-07-01"))-1
    temp1$month <- as.integer(substring(temp1$date,6,7))
  temp1$year <- as.integer(substring(temp1$date,1,4))
  temp2 <- 
    temp1 %>%
      group_by(state, year, month) %>%
      summarize(fire_count = sum(fire_count, na.rm = TRUE))
  if (i == 1){ 
  bushfire_summarised <- temp2
  } else {
  bushfire_summarised <- rbind(bushfire_summarised, temp2)
  }
}
  
  bushfire_summarised <- as.data.frame(bushfire_summarised)

####################################
#Server code
  server <- function(input, output) {
  
  mylabel <- reactive({
    if(input$data_input=='NSW'){
      label <- "Chart for NSW Data"
    }
    if(input$data_input=='VIC'){
      label <- "Chart for VIC Data"
    }
    if(input$data_input=='QLD'){
      label <- "Chart for QLD Data"
    }
    label
  })
  
  final_data <- reactive({
    # Select data according to selection
    if(input$data_input=='NSW'){
      calc_data <- bushfire_summarised[bushfire_summarised$state=="NSW",]
    }
    
    if(input$data_input=='VIC'){
      calc_data <- bushfire_summarised[bushfire_summarised$state=="VIC",]
    }
    
    if(input$data_input=='QLD'){
      calc_data <- bushfire_summarised[bushfire_summarised$state=="QLD",]
    }
    #------------------------------------------------------------------
    # Get data rows for selected year
    calc_data1 <- calc_data[calc_data$year >= input$year_range[1],]
    calc_data1 <- calc_data1[calc_data$year <= input$year_range[2], ] # From Year
    #------------------------------------------------------------------
    # Get data rows for selected year
    data.frame(calc_data1)
    #------------------------------------------------------------------
    
  })
  
  # Prepare "Data tab"
  output$data_table <- renderTable({
    final_data()
  })
  
  # Prepare Summary Tab
  calc_summary <- reactive({summary(final_data()["fire_count"])})
  
  output$summary_data <- renderPrint({
    calc_summary()
  })
  
  # Prepare Plot Tab
  output$charts <- renderPlot({
    plotdata <- 
      final_data() %>%
        group_by(month) %>%
        summarize(fire_count = mean(fire_count, na.rm = TRUE))
    ggplot(plotdata, aes(x=month, y=fire_count)) +
      geom_bar(stat="identity", fill="red") + 
      theme_minimal() + 
      scale_y_continuous(labels = scales::comma) + 
      scale_x_continuous(breaks=seq(1,12, by=1)) +
      xlab("Month") + ylab("Average Fire Count") + 
      ggtitle("Average Fire Count by Month")
      
  })
  
}

shinyApp(ui = ui, server = server)