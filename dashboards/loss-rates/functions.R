create_downloadable_table <- function(df){
  DT::datatable(
    df,
    extensions = c("Buttons"),
    options = list(
      dom = 'Bfrtip',
      autoWidth = TRUE,
      scrollX=TRUE,
      buttons = list(
        list(
          extend = "csv",
          text = "Download CSV",
          filename = "data",
          exportOptions = list(modifier = list(page = "all"))
        ),
        list(
          extend = "excel",
          text = "Download Excel",
          filename = "data",
          exportOptions = list(modifier = list(page = "all"))
        )
      )
    )
  )
}