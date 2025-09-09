export_model_table <- function(model, file_path) {
  # ---- packages ----
  require(broom.mixed)
  require(dplyr)
  require(flextable)
  require(officer)
  require(stringr)
  
  # ---- helpers ----
  prettify_terms <- function(x) {
    x %>%
      str_replace_all(":", " * ") %>%
      str_replace_all("\\(Intercept\\)", "Intercept") %>%
      str_replace_all("([A-Za-z_]+)([\\.:]*)([A-Z][a-z0-9]+$)", "\\1 [\\3]")
  }
  fmt_p <- function(p) {
    if (all(is.na(p))) return(rep("", length(p)))
    stars <- dplyr::case_when(
      p < 0.001 ~ "***",
      p < 0.01  ~ "**",
      p < 0.05  ~ "*",
      TRUE      ~ ""
    )
    base <- ifelse(!is.na(p) & p <= 0.001,
                   formatC(p, format = "e", digits = 2),
                   ifelse(!is.na(p), formatC(p, format = "f", digits = 3), ""))
    paste0(base, stars)
  }
  
  # ---- fixed effects ----
  fx <- broom.mixed::tidy(model, effects = "fixed", conf.int = TRUE)
  has_stat <- "statistic" %in% names(fx)
  has_se   <- "std.error" %in% names(fx)
  fixed_tbl <- fx %>%
    transmute(
      Variable = prettify_terms(term),
      `β`      = round(estimate, 2),
      `SE`     = if (has_se) round(std.error, 2) else NA_real_,
      `CI`     = paste0(round(conf.low, 2), " – ", round(conf.high, 2)),
      `t-value`= if (has_stat) round(statistic, 2) else NA_real_,
      `p-value`= fmt_p(p.value)
    )
  
  # ---- variance components (SDs) ----
  ran <- tryCatch(
    broom.mixed::tidy(model, effects = "ran_pars", scales = "sdcor"),
    error = function(e) NULL
  )
  if (!is.null(ran) && nrow(ran) > 0) {
    var_tbl <- ran %>%
      dplyr::filter(grepl("^sd__", term) | term %in% c("sigma","residual__sd")) %>%
      mutate(
        Component = dplyr::case_when(
          term %in% c("sigma","residual__sd") ~ "Residual",
          TRUE ~ dplyr::coalesce(group, term)
        ),
        SD = round(estimate, 2)
      ) %>%
      select(Variance = Component, SD)
  } else {
    sig <- tryCatch(stats::sigma(model), error = function(e) NA_real_)
    var_tbl <- tibble::tibble(Variance = "Residual", SD = round(sig, 2))
  }
  ll <- tryCatch(as.numeric(stats::logLik(model)), error = function(e) NA_real_)
  var_tbl <- var_tbl %>%
    mutate(`Goodness of fit` = ifelse(dplyr::row_number() == 1,
                                      paste0("Log likelihood  ", round(ll, 1)),
                                      ""))
  
  # ---- divider row with correct column types ----
  divider_row <- tibble::tibble(
    Variable = "Variance components",
    `β` = NA_real_,
    `SE` = NA_real_,
    `CI` = NA_character_,
    `t-value` = NA_real_,
    `p-value` = NA_character_
  )
  combined <- dplyr::bind_rows(fixed_tbl, divider_row)
  
  # ---- flextables ----
  ft_top <- flextable(combined) %>% autofit()
  ft_top <- bold(ft_top, part = "header", bold = TRUE)
  
  # merge the divider across columns (older flextable: no j=)
  div_idx <- nrow(combined)
  ft_top <- merge_h(ft_top, i = div_idx, part = "body")
  ft_top <- bold(ft_top, i = div_idx, bold = TRUE, part = "body")
  ft_top <- align(ft_top, i = div_idx, align = "left", part = "body")
  ft_top <- bg(ft_top, i = div_idx, j = seq_len(ncol(combined)), bg = "#F2F2F2", part = "body")
  
  ft_var <- flextable(var_tbl) %>% autofit()
  ft_var <- bold(ft_var, part = "header", bold = TRUE)
  
  # ---- export ----
  title_txt <- paste0(deparse(formula(model)))
  doc <- read_docx() %>%
    body_add_par(title_txt, style = "heading 2") %>%
    body_add_flextable(ft_top) %>%
    body_add_par("") %>%
    body_add_flextable(ft_var)
  
  print(doc, target = file_path)
}
