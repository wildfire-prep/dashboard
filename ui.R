dashboardPage(
  dashboardHeader(
    title = span(
      "Inspection Status Dashboard",
      style = "font-family: 'Open Sans', sans-serif; font-weight: bold;"
    ),
    titleWidth = 300
  ),
  dashboardSidebar(
    width = 300,
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    # Optional filters can be added here
    selectInput(
      "status_filter",
      "Filter by Status:",
      choices = c("All", "Compliant", "Non-Compliant"),
      selected = "All"
    ),
    # Add menu items for tab navigation
    sidebarMenu(
      menuItem("Map View", tabName = "map", icon = icon("map")),
      menuItem(
        "Data Visualization",
        tabName = "visualization",
        icon = icon("chart-bar")
      )
    )
  ),
  dashboardBody(
    tabItems(
      # Map tab
      tabItem(
        tabName = "map",
        tags$style(
          type = "text/css",
          "#inspection_map {height: calc(100vh - 80px) !important;}"
        ),
        leafletOutput("inspection_map") %>%
          withSpinner(type = 6, color = "#3c8dbc")
      ),

      # New data visualization tab
      tabItem(
        tabName = "visualization",
        fluidRow(
          box(
            title = "Inspection Status Summary",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotOutput("status_plot") %>%
              withSpinner(type = 6, color = "#3c8dbc")
          )
        ),
        fluidRow(
          box(
            title = "Inspection Details",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            DTOutput("inspection_table") %>%
              withSpinner(type = 6, color = "#3c8dbc")
          )
        )
      )
    )
  )
)
