ukraine_palette <- list(
  ukraine_blue = "#0057b7",
  ukraine_blue_light = "#ACC8E7",
  ukraine_blue_very_light = "#EDF4FA",
  ukraine_blue_dark = "#00346d",
  ukraine_yellow = "#ffd700",
  ukraine_yellow_darkened = "#d6b500",
  text_colour = "#555555"
)


ukraine_plot_theme <- function(){
  ukraine_blue <- "#0057b7"
  ukraine_blue_light <- "#ACC8E7"
  ukraine_blue_very_light <- "#EDF4FA"
  ukraine_blue_dark <- "#00346d"
  ukraine_yellow <- "#ffd700"
  ukraine_yellow_darkened <- "#d6b500"
  text_colour <- "#555555"
  
  theme(plot.title = element_text(size = 20, colour = ukraine_palette$text_colour),
        strip.text.x = element_text(size = 16, colour = ukraine_palette$text_colour),
        axis.title = element_text(size = 15, face="bold", colour = ukraine_palette$text_colour),
        axis.text.x = element_text(
          angle = 30, hjust = 1, colour = ukraine_palette$text_colour, size = 13
        ),
        axis.text.y = element_text(size = 13),
        panel.background = element_rect(
          fill = ukraine_palette$ukraine_blue_very_light, colour = ukraine_palette$ukraine_blue_light
        ),
        legend.title = element_text(size = 12, face = "bold", colour = ukraine_palette$text_colour)
  )
}