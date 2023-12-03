
fluidPage(
  titlePanel("Precipitation Data Visualization"),
  
  sidebarLayout(
    sidebarPanel(
      # Inputs for plot_annual_precipitation_range
      numericInput("start_year", "Start Year", value = 2021, min = 1950, max = 2022),
      numericInput("end_year", "End Year", value = 2022, min = 1950, max = 2022),
      selectInput("start_month", "Start Month", choices = substr(month.name, 1, 3)),
      selectInput("end_month", "End Month", choices = substr(month.name, 1, 3)),
      
      # Inputs for plot_extreme_events_US
      numericInput("year_extreme", "Year for Extreme Events", value = 1983, min = 1950, max = 2022),
      sliderInput("percentile", "Percentile for Extreme Events", min = 0.9, max = 1, value = 0.99, step = 0.01),
      
      # Inputs for plot_day_interactive
      numericInput("year_day", "Year", value = 1983),
      selectInput("month_day", "Month", choices = substr(month.name, 1, 3)),
      numericInput("day_day", "Day", value = 1, min = 1, max = 31),
      
      actionButton("toggle_plot", "Toggle Plot"),
      textOutput("current_plot_label")
      
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

