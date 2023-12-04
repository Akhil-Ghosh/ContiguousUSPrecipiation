fluidPage(
  titlePanel("Precipitation Data Visualization"),
  
  sidebarLayout(
    sidebarPanel(
      wellPanel(
        title = h4("Annual Precipitation Range"),
        dateInput("start_date", "Start Date", value = "2021-01-01", startview = "year"),
        dateInput("end_date", "End Date", value = "2022-01-01", startview = "year"),
        numericInput("min_precip", "Minimum Precipitation (mm)", value = 0),
        numericInput("max_precip", "Maximum Precipitation (mm)", value = 1000),
        actionButton("update_plot", "Update Plot"),
        actionButton("toggle_plot", "Toggle Plot"),
        actionButton("save_plot", "Save Plot"),
        textOutput("current_plot_label")
      ),
      
      wellPanel(
        title = h4("Extreme Events"),
        numericInput("year_extreme", "Year", value = 1983, min = 1950, max = 2022),
        sliderInput("percentile", "Percentile", min = 0.9, max = 1, value = 0.99, step = 0.01)
      ),
      
      wellPanel(
        title = h4("Day Plot"),
        dateInput("day_date", "Select Date", value = "1983-01-01", startview = "year")
      )
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Annual Precipitation Range", plotOutput("annual_plot")),
        tabPanel("Extreme Events", plotOutput("extreme_plot")),
        tabPanel("Day Plot", plotlyOutput("day_plot"))
      )
    )
  )
)
