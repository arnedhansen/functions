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
  p_base <- function(p) {
    ifelse(!is.na(p) & p <= 0.001,
           formatC(p, format = "e", digits = 2),
           ifelse(!is.na(p), formatC(p, format = "f", digits = 3), ""))
  }
  p_stars <- function(p) dplyr::case_when(
    is.na(p) ~ "",
    p < 0.001 ~ "***",
    p < 0.01  ~ "**",
    p < 0.05  ~ "*",
    TRUE      ~ ""
  )
  
  # ---- fixed effects ----
  fx <- broom.mixed::tidy(model, effects = "fixed", conf.int = TRUE)
  has_stat <- "statistic" %in% names(fx)
  has_se   <- "std.error" %in% names(fx)
  
  fixed_tbl <- fx %>%
    transmute(
      Variable = prettify_terms(term),
      `β`       = round(estimate, 3),
      `SE`      = if (has_se) round(std.error, 3) else NA_real_,
      `CI`      = paste0(round(conf.low, 3), " – ", round(conf.high, 3)),
      `t-value` = if (has_stat) round(statistic, 3) else NA_real_,
      p_num     = p_base(p.value),
      p_star    = p_stars(p.value),
      `p-value` = ""   # filled via flextable::compose
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
  
  # ---- flextables ----
  ft_top <- flextable::flextable(fixed_tbl) %>% flextable::autofit()
  ft_top <- flextable::bold(ft_top, part = "header", bold = TRUE)
  
  # p-value with bold stars
  ft_top <- flextable::compose(
    ft_top, j = "p-value",
    value = flextable::as_paragraph(
      flextable::as_chunk(fixed_tbl$p_num),
      flextable::as_chunk(fixed_tbl$p_star, props = officer::fp_text(bold = TRUE))
    )
  )
  ft_top <- flextable::delete_columns(ft_top, c("p_num","p_star"))
  
  ft_var <- flextable::flextable(var_tbl) %>% flextable::autofit()
  ft_var <- flextable::bold(ft_var, part = "header", bold = TRUE)
  
  # ---- export ----
  title_txt <- paste0(deparse(formula(model)))
  doc <- officer::read_docx() %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(title_txt, officer::fp_text(bold = TRUE, font.size = 15)))) %>%
    officer::body_add_par("") %>%
    flextable::body_add_flextable(value = ft_top) %>%
    officer::body_add_par("") %>%
    officer::body_add_fpar(officer::fpar(officer::ftext("Variance components", officer::fp_text(bold = TRUE, font.size = 12)))) %>%
    officer::body_add_par("") %>%
    flextable::body_add_flextable(value = ft_var)
  
  # ---- emmeans (back-transformed means + pairwise contrasts) ----
  if ("Condition" %in% all.vars(formula(model))) {
    if (requireNamespace("emmeans", quietly = TRUE)) {
      emm <- tryCatch(
        emmeans::emmeans(model, ~ Condition, type = "response"),
        error = function(e) NULL
      )
      if (!is.null(emm)) {
        # Estimated marginal means
        emm_tbl <- as.data.frame(emm)
        emm_tbl <- emm_tbl %>%
          mutate(
            Estimate = round(response, 3),
            SE = round(SE, 3),
            LowerCI = round(as.numeric(asymp.LCL), 3),
            UpperCI = round(as.numeric(asymp.UCL), 3)
          ) %>%
          select(Condition, Estimate, SE, LowerCI, UpperCI)
        
        ft_emm <- flextable::flextable(emm_tbl) %>%
          flextable::autofit() %>%
          flextable::bold(part = "header", bold = TRUE)
        
        # Pairwise contrasts
        contr <- tryCatch(
          emmeans::pairs(emm, adjust = "tukey", type = "response"),
          error = function(e) NULL
        )
        if (!is.null(contr)) {
          contr_tbl <- as.data.frame(contr)
          # Back-transform estimates if present
          if ("ratio" %in% names(contr_tbl)) {
            contr_tbl$Estimate <- contr_tbl$ratio
          } else if ("odds.ratio" %in% names(contr_tbl)) {
            contr_tbl$Estimate <- contr_tbl$odds.ratio
          } else {
            contr_tbl$Estimate <- contr_tbl$estimate
          }
          
          contr_tbl <- contr_tbl %>%
            mutate(
              Contrast = contrast,
              Estimate = round(Estimate, 3),
              SE = round(SE, 3),
              LowerCI = round(as.numeric(asymp.LCL), 3),
              UpperCI = round(as.numeric(asymp.UCL), 3),
              p = round(p.value, 4)
            ) %>%
            select(Contrast, Estimate, SE, LowerCI, UpperCI, p)
          
          ft_contr <- flextable::flextable(contr_tbl) %>%
            flextable::autofit() %>%
            flextable::bold(part = "header", bold = TRUE)
        }
        
        # Add both to document
        doc <- doc %>%
          officer::body_add_par("") %>%
          officer::body_add_fpar(officer::fpar(
            officer::ftext("Estimated marginal means (back-transformed)",
                           officer::fp_text(bold = TRUE, font.size = 12))
          )) %>%
          officer::body_add_par("") %>%
          flextable::body_add_flextable(value = ft_emm)
        
        if (exists("ft_contr")) {
          doc <- doc %>%
            officer::body_add_par("") %>%
            officer::body_add_fpar(officer::fpar(
              officer::ftext("Pairwise contrasts (Tukey-adjusted)",
                             officer::fp_text(bold = TRUE, font.size = 12))
            )) %>%
            officer::body_add_par("") %>%
            flextable::body_add_flextable(value = ft_contr)
        }
      }
    }
  }
  
  print(doc, target = file_path)
}
