fluidPage(
  titlePanel("Precipitation Data Visualization"),
  sidebarLayout(
    sidebarPanel(
      wellPanel(
        title = h4("Annual Precipitation Range"),
        fluidRow(
          column(6, 
                 dateInput("start_date", "Start Date", value = "2022-01-01", min = "1948-01-01", max = "2022-12-31", startview = "year")
          ),
          column(6, 
                 dateInput("end_date", "End Date", value = "2022-12-31", min = "1948-01-01", max = "2022-12-31", startview = "year")
          )
        ),
        fluidRow(
          column(6,
                 sliderInput("min_precip", "Minimum Precipitation (mm)", min = 0, max = 5000, value = 0,step=100)
          ),
          column(6,
                 sliderInput("max_precip", "Maximum Precipitation (mm)", min = 0, max = 5000, value = 2000,step=100)
          )
        ),
        actionButton("toggle_plot", "Toggle Plot"),
        #downloadButton("save_plot", "Save Plot"),
        textOutput("current_plot_label")
      ),
      wellPanel(
        title = h4("Extreme Events"),
        numericInput("year_extreme", "Year", value = 2022, min = 1948, max = 2022),
        sliderInput("percentile", "Percentile", min = 0.9, max = 1, value = 0.99, step = 0.01),
        numericInput("limits", "Limit", value = 10, min = 1, max = 1000)
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
