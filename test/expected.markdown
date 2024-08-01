::: {#table:1}
```{r table-1, echo = FALSE, results = 'asis'}
table_1_data <- read.csv("table_data_1.csv")
knitr::kable(table_1_data, caption="Image format support in various markup/typesetting languages.")
```
:::

::: {#table1}
```{r table-2, echo = FALSE, results = 'asis'}
table_2_data <- read.csv("table_data_2.csv")
knitr::kable(table_2_data, caption="An Example Table")
```
:::
