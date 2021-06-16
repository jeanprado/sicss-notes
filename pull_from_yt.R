# import ------------------------------------------------------------------
raw <- readxl::read_excel("data-raw/youtube-database-day4.xlsx") |>
  janitor::clean_names()

# get channel ids
channel_ids <- raw |> dplyr::distinct(channel_id) |> dplyr::pull(channel_id)

# auth yt api
tuber::yt_oauth(app_id = Sys.getenv("YT_APP_ID"),
                app_secret = Sys.getenv("YT_APP_SECRET"))

# creates function to pull channel stats
get_channel_stats <- function(channel_id) {
  raw <- tuber::get_channel_stats(channel_id = channel_id)

  raw |> purrr::pluck("statistics") |> tibble::as_tibble() |>
    dplyr::bind_cols(id = raw |> purrr::pluck("id"),
                     description = raw |> purrr::pluck("snippet") |>
                       purrr::pluck("description"))
}

# tidy --------------------------------------------------------------------

# pull data from youtube (de um jeito porco, mas foi o que o tempo permitiu)
first_1000 <- purrr::map_dfr(channel_ids[1:1000], get_channel_stats)
first_2000 <- purrr::map_dfr(channel_ids[1001:2000], get_channel_stats)
first_3000 <- purrr::map_dfr(channel_ids[2001:2969], get_channel_stats)

# join all & tidy
channel_stats <- dplyr::bind_rows(first_1000, first_2000, first_3000) |>
  dplyr::select(channel_id=id, channel_description=description,
                channel_view_count=viewCount, tidyselect::everything()) |>
  janitor::clean_names()

# export
channel_stats |> readr::write_csv("data-raw/channel_stats.csv")

# code to join two datasets
raw <- raw %>% dplyr::left_join(readr::read_csv("data-raw/channel_stats.csv"),
                               by = "channel_id")
