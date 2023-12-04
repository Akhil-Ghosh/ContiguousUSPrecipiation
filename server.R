function(input, output, session) {
  # Reactive value to toggle between plots
  current_plot <- reactiveVal("range")
  
  # Observe event for the toggle plot button
  observeEvent(input$toggle_plot, {
    if(current_plot() == "range") {
      current_plot("US")
    } else {
      current_plot("range")
    }
  })
  
  # Extracting year and month from date inputs
  start_year <- reactive({ as.numeric(format(as.Date(input$start_date), "%Y")) })
  end_year <- reactive({ as.numeric(format(as.Date(input$end_date), "%Y")) })
  start_month <- reactive({ format(as.Date(input$start_date), "%b") })
  end_month <- reactive({ format(as.Date(input$end_date), "%b") })
  start_day <- reactive({ as.numeric(format(as.Date(input$start_date), "%d")) })
  end_day <- reactive({ as.numeric(format(as.Date(input$end_date), "%d")) })
  
  min_precip <- reactive({ input$min_precip })
  max_precip <- reactive({ input$max_precip })
  
  # Existing reactive expressions for plot_day_interactive
  
  year_day <- reactive({ as.numeric(format(as.Date(input$day_date), "%Y")) })
  month_day <- reactive({ format(as.Date(input$day_date), "%b") })
  day_day <- reactive({ as.numeric(format(as.Date(input$day_date), "%d")) })
  
  
  # Existing reactive expression for plot_extreme_events_US
  perc <- reactive({ input$percentile })
  p_matrix <- reactive({ get_Xth_percentile(percentile = perc()) })
  
  # Render plot_annual_precipitation_range or plot_annual_precipitation_US
  output$annual_plot <- renderPlot({
    if(current_plot() == "range") {
      plot_annual_precipitation_range(start_year(), end_year(), start_month(), end_month(), start_day(),end_day(),min_precip(), max_precip())
    } else {
      plot_annual_precipitation_US(start_year(), end_year(), start_month(), end_month(),start_day(),end_day(), min_precip(), max_precip())
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