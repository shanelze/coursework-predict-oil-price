# Predicting Oil Prices Using Regression and Decision Trees

This project analyzes macroeconomic indicators to predict oil prices using both linear regression and CART (Classification and Regression Tree) models. It aims to understand the key drivers of oil price fluctuations and assess model accuracy based on RMSE.

---

## 📊 Dataset

The dataset `OilPrice.csv` contains variables such as:
- Price
- GDP Index
- Oil Reserve
- Oil Production
- US Dollar Index
- SNP500 Index
- US PPI
- Year, Month

Time series data is visualized using converted date fields.

---

## 🧠 Models Used

### Linear Regression
- Trains two models: a full model and a reduced model excluding less impactful predictors.
- Calculates RMSE on both training and test sets.
- Evaluates multicollinearity using VIF.

### CART Model
- Builds a regression tree with `rpart`.
- Prunes the tree using cross-validation error cap.
- Computes variable importance (scaled %).
- Evaluates RMSE on both training and test sets.

---

## 📈 Performance

| Model           | RMSE (Train) | RMSE (Test) |
|----------------|--------------|-------------|
| Linear Model    | ~3.83        | ~5.06       |
| CART (Pruned)   | ~3.81        | ~5.06       |

US PPI was found to be the most significant predictor of oil price.

---

## 📦 Dependencies

- `data.table`
- `ggplot2`
- `rpart`, `rpart.plot`
- `caTools`
- `corrplot`
- `car`

---

## 🛠️ How to Run

1. Place `OilPrice.csv` in your working directory.
2. Update `setwd()` in the script to match your local path.
3. Run `predict-oil-price.R` using RStudio or the R console.

---

## 📌 Notes

- Assumes `OilPrice.csv` is clean and pre-formatted.
- Uses a 70/30 train-test split.
- Results may vary slightly due to random sampling.
