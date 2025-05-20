function(input, output, session) {
  # Transform the data to WGS84 (EPSG:4326) for Leaflet
  training_data <- reactive({
    data <- st_transform(training_geometries_2019, crs = 4326)

    if (input$status_filter != "All") {
      data <- data %>% filter(status == input$status_filter)
    }

    data
  })

  # Create a color palette for the status
  status_palette <- reactive({
    colorFactor(
      palette = c("#00FF00", "#FF0000"),
      domain = c("Compliant", "Non-Compliant"),
      na.color = "transparent"
    )
  })

  # Base map creation with Esri World Imagery
  output$inspection_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(
        providers$Esri.WorldImagery,
        options = providerTileOptions(
          attribution = 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
        )
      ) %>%
      setView(lng = -120.0, lat = 34.7, zoom = 9) %>% # Updated coordinates for Santa Barbara County
      addLegend(
        position = "bottomright",
        pal = status_palette(),
        values = c("Compliant", "Non-Compliant"),
        title = "Inspection Status",
        opacity = 0.9
      )
  })

  # Update map when data changes
  observe({
    pal <- status_palette()

    leafletProxy("inspection_map", data = training_data()) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~ pal(status),
        fillOpacity = 0.7,
        color = "#FFFFFF",
        weight = 1,
        opacity = 1,
        dashArray = "3",
        label = ~ paste("Status:", status),
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#FFFF00",
          dashArray = "",
          fillOpacity = 0.9,
          bringToFront = TRUE
        ),
        group = "inspections"
      )
  })

  # Status summary plot
  output$status_plot <- renderPlot({
    # Convert sf object to dataframe and count by status
    status_summary <- training_data() %>%
      st_drop_geometry() %>%
      count(status) %>%
      mutate(
        percentage = n / sum(n) * 100,
        status = factor(status, levels = c("Compliant", "Non-Compliant"))
      )

    # Create bar plot with black text above bars
    ggplot(status_summary, aes(x = status, y = n, fill = status)) +
      geom_bar(stat = "identity", width = 0.6) +
      geom_text(
        aes(label = paste0(round(percentage, 1), "%"), y = n + max(n) * 0.05),
        color = "black",
        size = 5,
        fontface = "bold"
      ) +
      scale_fill_manual(
        values = c("Compliant" = "#00FF00", "Non-Compliant" = "#FF0000")
      ) +
      labs(
        title = "Inspection Status Distribution",
        x = "Status",
        y = "Count"
      ) +
      # Add some extra space at the top for labels
      scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14, face = "bold"),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5)
      )
  })

  # Data table - updated implementation
  output$inspection_table <- renderDT({
    # Create data table with relevant columns
    datatable_data <- training_data() %>%
      st_drop_geometry() %>%
      as.data.frame() # Explicitly convert to data frame

    # Create interactive data table
    datatable(
      datatable_data,
      options = list(
        pageLength = 10,
        scrollX = TRUE
      ),
      rownames = FALSE,
      filter = 'top'
    ) %>%
      formatStyle(
        'status',
        backgroundColor = styleEqual(
          c("Compliant", "Non-Compliant"),
          c("#CCFFCC", "#FFCCCC")
        )
      )
  })
}
