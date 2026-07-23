# ============================================================
# Project 1: Time Series Decomposition and Cleaning
# Variable: Euro Area (EA20) Industrial Production Index
#           from Eurostat (sts_inpr_m)
# ============================================================

# ----- 0. Install / load packages -----
if (!requireNamespace("eurostat", quietly = TRUE))  install.packages("eurostat")
if (!requireNamespace("tseries",  quietly = TRUE))  install.packages("tseries")
if (!requireNamespace("forecast", quietly = TRUE))  install.packages("forecast")
if (!requireNamespace("seasonal", quietly = TRUE))  install.packages("seasonal")
if (!requireNamespace("ggplot2",  quietly = TRUE))  install.packages("ggplot2")
if (!requireNamespace("dplyr",    quietly = TRUE))  install.packages("dplyr")
if (!requireNamespace("tsoutliers",quietly = TRUE)) install.packages("tsoutliers")

library(eurostat)
library(tseries)
library(forecast)
library(seasonal)
library(ggplot2)
library(dplyr)

# ----- 1. Data Selection -----
# Dataset: Monthly Industrial Production Index for the Euro Area (EA20)
# Source : Eurostat — sts_inpr_m
# Filters: nace_r2 = "B-D"  (total industry excl. construction)
#          s_adj   = "NSA"   (not seasonally adjusted — raw data)
#          unit    = "I15"   (index, 2015=100)
#          geo     = "EA20"

raw <- get_eurostat("sts_inpr_m",
                    filters = list(
                      nace_r2 = "B-D",
                      s_adj   = "NSA",
                      unit    = "I15",
                      geo     = "EA20"
                    ),
                    time_format = "date")

# Keep 2000-01 to 2023-12 for a balanced 24-year window
df <- raw %>%
  filter(time >= as.Date("2000-01-01"),
         time <= as.Date("2023-12-01")) %>%
  arrange(time)

# Convert to monthly ts object
ipi_ts <- ts(df$values, start = c(2000, 1), frequency = 12)

# ----- 2. Descriptive Analysis -----
cat("=== Descriptive Statistics ===\n")
print(summary(ipi_ts))
cat("Observations :", length(ipi_ts), "\n")
cat("Std. Dev.    :", round(sd(ipi_ts), 3), "\n")
cat("Skewness     :", round(moments::skewness(ipi_ts), 3), "\n")
cat("Kurtosis     :", round(moments::kurtosis(ipi_ts), 3), "\n")

# Time-series plot
autoplot(ipi_ts) +
  labs(title = "Euro Area Industrial Production Index (2000–2023)",
       subtitle = "Monthly, NSA, 2015=100",
       x = "Date", y = "Index") +
  theme_minimal()
ggsave("fig1_raw_series.png", width = 9, height = 4)

# ----- 3. Feature Identification -----
# Lag/ACF/PACF
png("fig2_acf_pacf.png", width = 900, height = 400)
par(mfrow = c(1,2))
acf(ipi_ts,  lag.max = 48, main = "ACF — Raw IPI")
pacf(ipi_ts, lag.max = 48, main = "PACF — Raw IPI")
dev.off()

# Classical decomposition (multiplicative — index data with proportional variation)
decomp_mult <- decompose(ipi_ts, type = "multiplicative")
png("fig3_decomposition.png", width = 900, height = 700)
plot(decomp_mult)
dev.off()

# ----- 4. Seasonal Adjustment — X-13ARIMA-SEATS -----
x13_model <- seas(ipi_ts)
summary(x13_model)

ipi_sa  <- final(x13_model)          # seasonally adjusted series
ipi_irr <- irregular(x13_model)      # irregular component

autoplot(cbind(Raw = ipi_ts, `SA (X-13)` = ipi_sa)) +
  labs(title = "IPI: Raw vs. Seasonally Adjusted",
       x = "Date", y = "Index") +
  theme_minimal()
ggsave("fig4_sa_comparison.png", width = 9, height = 4)

# Seasonal subseries plot (verify removal)
png("fig5_seasonal_subseries.png", width = 900, height = 500)
monthplot(ipi_sa, main = "Seasonal Sub-series — SA Series")
dev.off()

# ----- 5. Stationarity Tests -----
# 5a. ADF test on raw series
cat("\n=== ADF Test — Raw Series ===\n")
print(adf.test(ipi_ts))

# 5b. ADF on SA series
cat("\n=== ADF Test — SA Series ===\n")
print(adf.test(ipi_sa))

# 5c. KPSS test
cat("\n=== KPSS Test — SA Series ===\n")
print(kpss.test(ipi_sa))

# 5d. First difference of SA series
ipi_d1 <- diff(ipi_sa)
cat("\n=== ADF Test — First-Differenced SA ===\n")
print(adf.test(diff(ipi_sa)))
cat("\n=== KPSS Test — First-Differenced SA ===\n")
print(kpss.test(diff(ipi_sa)))

autoplot(diff(ipi_sa)) +
  labs(title = "First-Differenced SA Industrial Production",
       x = "Date", y = "Δ Index") +
  theme_minimal()
ggsave("fig6_differenced.png", width = 9, height = 4)

# ----- 6. Outlier Detection & Treatment -----
# Use tsoutliers / auto.arima + outlier detection
ipi_arima <- auto.arima(ipi_sa, stepwise = FALSE)
outliers  <- tsoutliers::tso(ipi_sa, types = c("AO","TC","LS","IO"))
print(outliers)

# Plot outlier-cleaned series
png("fig7_outliers.png", width = 900, height = 450)
plot(outliers)
dev.off()

ipi_clean <- tsclean(ipi_sa)   # fast robust cleaning via STL + Winsorisation
autoplot(cbind(`SA` = ipi_sa, `SA + Cleaned` = ipi_clean)) +
  labs(title = "SA IPI: Before and After Outlier Treatment",
       x = "Date", y = "Index") +
  theme_minimal()
ggsave("fig8_cleaned.png", width = 9, height = 4)

# ----- 7. Model Selection -----
# After differencing and cleaning, check ACF/PACF for candidate models
ipi_final <- diff(ipi_clean)

png("fig9_final_acf.png", width = 900, height = 400)
par(mfrow = c(1, 2))
acf(ipi_final,  lag.max = 36, main = "ACF — Final Processed Series")
pacf(ipi_final, lag.max = 36, main = "PACF — Final Processed Series")
dev.off()

# Auto-select ARIMA
best_model <- auto.arima(ipi_clean, d = 1, stepwise = FALSE,
                          approximation = FALSE, trace = TRUE)
cat("\n=== Best ARIMA Model ===\n")
print(summary(best_model))

# Ljung-Box residual test
cat("\n=== Ljung-Box Test on Residuals ===\n")
print(Box.test(residuals(best_model), lag = 24, type = "Ljung-Box"))

# Residual diagnostics
png("fig10_residuals.png", width = 900, height = 600)
checkresiduals(best_model)
dev.off()

cat("\nAll figures saved. Analysis complete.\n")
