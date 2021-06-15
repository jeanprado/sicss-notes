### youtube ###

# autentica no youtube
tuber::yt_oauth(app_id = Sys.getenv("YT_APP_ID"),
                app_secret = Sys.getenv("YT_APP_SECRET"))

# busca
b <- "(moeda OR chave OR magnetismo OR magnético OR gruda OR magnetizar) AND (vacina OR astrazeneca OR pfizer OR vacinas OR coronavac)"

# baixa dados brutos
raw_search <- tuber::yt_search(b)

# trata os dados
search <- raw_search |>
  dplyr::mutate(publishedAt = lubridate::ymd_hms(publishedAt)) |>
  dplyr::filter(publishedAt >= "2021-05-30",
                dplyr::across(c(title, description),
                              \(x) stringr::str_detect(x, "vacinas?|astra ?zeneca|pfizer|corona ?vac"))) |>
  dplyr::select(video_id, publishedAt, title, description, channelTitle)

# puxa outros dados
b <- tuber::get_channel_stats(channel_id="UCHIWQgafQbD0rLK78JakK5Q")
a <- tuber::get_video_details(video_id = "ifHEw0YB-Eo", part = "statistics")

### google trends ###
gtrendsR::gtrends(keyword = "magnetismo", geo = "BR",
                  time = "today 1-m", gprop = "web",
                  low_search_volume = TRUE, hl = "pt-BR")

### twitter ###
# raw <- rtweet::search_tweets(q = b, n = 18000,
#                       include_rts = FALSE, type = "mixed")
