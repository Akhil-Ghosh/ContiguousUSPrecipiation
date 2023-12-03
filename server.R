
function(input, output, session) {
  # Render plot_annual_precipitation_range
  current_plot <- reactiveVal("range")

  observeEvent(input$toggle_plot, {
    if(current_plot() == "range") {
      current_plot("US")
    } else {
      current_plot("range")
    }
  })
  
  
  start_year <- reactive({ input$start_year })
  end_year <- reactive({ input$end_year })
  start_month <- reactive({ input$start_month })
  end_month <- reactive({ input$end_month })

  year_day <- reactive({ input$year_day })
  month_day <- reactive({ input$month_day })
  day_day <- reactive({ input$day_day })
  
  perc <- reactive({input$percentile})
  p_matrix <- reactive({get_Xth_percentile(percentile=perc())})
  
  
  #plotting cumulative range:
  
  output$annual_plot <- renderPlot({
    if(current_plot() == "range") {
      plot_annual_precipitation_range(start_year(), end_year(), start_month(), end_month())
    } else {
      plot_annual_precipitation_US(start_year(), end_year(), start_month(), end_month())
    }
  })
  
  
  # Render plot_extreme_events_US
  output$extreme_plot <- renderPlot({
    plot_extreme_events_US(input$year_extreme, p_matrix())
  })
  
  # Render plot_day_interactive
  output$day_plot <- renderPlotly({
    plot_day_interactive(year_day(), month_day(), day_day())
  })
}
