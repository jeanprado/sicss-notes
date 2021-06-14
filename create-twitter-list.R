# imports original spreadsheet as a tibble (tidyverse's data.frame)
raw <- googlesheets4::read_sheet("1QgFvtoYssbV6pwXjTTnimZcPPO8lYfhRBIOyl7DrbEM")

# tidy data, removing twitter URL, @ sign or NA values
twitter <- raw |> dplyr::select(users=`Twitter Page`) |>
  dplyr::mutate(users = stringr::str_remove_all(users, "\\?(.*)"),
                users = stringr::str_remove_all(users, "https://twitter.com/"),
                users = stringr::str_remove_all(users, "twitter.com/"),
                users = stringr::str_remove_all(users, "@"),
                users = dplyr::na_if(users, "N/A"),
                users = dplyr::na_if(users, "n/a")) |>
  tidyr::drop_na() |> dplyr::distinct()

# create a Twitter list using rtweet
rtweet::post_list(users = twitter$users,
                  name = "2021 SICSS Participants")

