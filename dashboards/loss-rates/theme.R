ukraine_palette <- list(
  ukraine_blue = "#0057B7",
  ukraine_blue_medium = "#6298D2",
  ukraine_blue_light = "#ACC8E7",
  ukraine_blue_lighter = "#DDE9F5",
  ukraine_blue_very_light = "#EDF4FA",
  ukraine_blue_light_muted = "#C1CDD9",
  ukraine_blue_dark = "#00346d",
  ukraine_yellow = "#FFD700",
  ukraine_yellow_light = "#FFF9DB",
  ukraine_yellow_darkened = "#d6b500",
  ukraine_yellow_very_dark = "#A18800",
  ukraine_yellow_highlight = "#FFF500",
  text_colour = "#555555"
)


ukraine_plot_theme <- function(){
  theme(plot.title = element_text(size = 20, colour = ukraine_palette$text_colour),
        strip.text.x = element_text(size = 16, colour = ukraine_palette$text_colour),
        axis.title = element_text(size = 15, face="bold", colour = ukraine_palette$text_colour),
        axis.text.x = element_text(
          angle = 30, hjust = 1, colour = ukraine_palette$text_colour, size = 13
        ),
        axis.text.y = element_text(size = 13),
        panel.background = element_rect(
          fill = ukraine_palette$ukraine_blue_lighter
        ),
        legend.title = element_text(size = 12, face = "bold", colour = ukraine_palette$text_colour),
        strip.background = element_rect(fill = ukraine_palette$ukraine_blue_light_muted)
  )
}