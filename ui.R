fluidPage(
  titlePanel("Precipitation Data Visualization"),
  sidebarLayout(
    sidebarPanel(
      wellPanel(
        title = h4("Annual Precipitation Range"),
        fluidRow(
          column(6, 
                 dateInput("start_date", "Start Date", value = "2022-01-01", startview = "year")
          ),
          column(6, 
                 dateInput("end_date", "End Date", value = "2022-12-31", startview = "year")
          )
        ),
        numericInput("min_precip", "Minimum Precipitation (mm)", value = 0),
        numericInput("max_precip", "Maximum Precipitation (mm)", value = 2000),
        actionButton("toggle_plot", "Toggle Plot"),
        #downloadButton("save_plot", "Save Plot"),
        textOutput("current_plot_label")
      ),
      wellPanel(
        title = h4("Extreme Events"),
        numericInput("year_extreme", "Year", value = 2022, min = 1950, max = 2022),
        sliderInput("percentile", "Percentile", min = 0.9, max = 1, value = 0.99, step = 0.01)
      ),
      wellPanel(
        title = h4("Day Plot"),
        dateInput("day_date", "Select Date", value = "2022-01-01", startview = "year")
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
