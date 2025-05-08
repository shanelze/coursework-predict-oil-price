
library(data.table)
library(rpart)
library(ggplot2)
library(corrplot)

setwd("C:/Users/Yan Tong School/Downloads")
dt = fread("OilPrice.csv")
View(dt)

# Visualisation ----------------------------

viz = dt

viz$date <- as.Date(paste(viz$Year, ifelse(nchar(viz$Month) == 2, viz$Month, paste0("0", viz$Month)), "01", sep = "-"), format = "%Y-%m-%d")

corrplot(cor(dt[,.(Price,`GDP Index`,`Oil Reserve`,`Oil Production`,`US Dollar Index`,`SNP500Index`,`US PPI`)], use="complete.obs"),type="lower")
cor(dt[,.(Price,`GDP Index`,`Oil Reserve`,`Oil Production`,`US Dollar Index`,`SNP500Index`,`US PPI`)])

ggplot(viz, aes(date, Price)) + geom_line()
ggplot(viz, aes(date, `Oil Reserve`)) + geom_line()

# ----------------------------------------

# Linear Regression ----------------------

library(caTools)

set.seed(2)

train <- sample.split(Y = dt$Price, SplitRatio = 0.7)
trainset <- subset(dt, train == T)
testset <- subset(dt, train == F)

m1 = lm(Price ~ . -Month -Year, data = trainset)
summary(m1)

m2 = lm(Price ~ . -Month -Year -`GDP Index` -`Oil Reserve` -SNP500Index, data = trainset)
summary(m2)

library(car)
vif(m2)

par(mfrow = c(2,2))
plot(m2)
par(mfrow = c(1,1))

# Trainset RMSE
RMSE.m2.train <- sqrt(mean(residuals(m2)^2))
RMSE.m2.train

# Testset RMSE 
predict.m2.test <- predict(m2, newdata = testset)
testset.error <- testset$Price - predict.m2.test
RMSE.m2.test <- sqrt(mean(testset.error^2))
summary(abs(testset.error))
RMSE.m2.test

# -------------------------------------

library(rpart)
library(rpart.plot) 

oil_price_numeric = dt[,.(Price,`GDP Index`,`Oil Reserve`,`Oil Production`,`US Dollar Index`,`SNP500Index`,`US PPI`)]
set.seed(2)

train <- sample.split(Y = oil_price_numeric$Price, SplitRatio = 0.7)
trainset <- subset(oil_price_numeric, train == T)
testset <- subset(oil_price_numeric, train == F)

cart1 <- rpart(Price ~ ., data = trainset, method = 'anova', control = rpart.control(minsplit = 2, cp = 0))
#Cart model is trained on trainset, with Price as the outcome variable.

rpart.plot(cart1, nn = T, main = "CART Tree for Oil Price")#CART Tree (without pruning)

printcp(cart1)
plotcp(cart1)
#Too many trees to find the optimal tree by just looking at the graph.Thus, we have to write a code to calculate which tree is optimal.

CVerror.cap <- cart1$cptable[which.min(cart1$cptable[,"xerror"]), "xerror"] + cart1$cptable[which.min(cart1$cptable[,"xerror"]), "xstd"] 
#This gives us the CV error cap, which is equal to the Minimum CV error+Std Deviation.

i <- 1; j<- 4 
#i indicates row number; j=4 as CV error is the 4th column in the cptable.

while (cart1$cptable[i,j] > CVerror.cap) {  i <- i + 1
}
cp.opt = ifelse(i > 1, sqrt(cart1$cptable[i,1] * cart1$cptable[i-1,1]), 1)
cp.opt
i
#i=12 shows that the 12th tree is optimal.

#Now, we prune the tree, until we get the optimal tree.
cart2 <- prune(cart1, cp = cp.opt)
printcp(cart2, digits = 3) ##Root node error: 210104/218=964
print(cart2)
rpart.plot(cart2, nn = T, main = "Optimal Tree for Oil Price")
#12 terminal nodes

cart2$variable.importance

# Scaling Variable Impt so as to represent as percentage impt --------------------
scaledVarImpt <-round(100*cart2$variable.importance/sum(cart2$variable.importance))

scaledVarImpt[scaledVarImpt > 3]  # Print all var impt > cutoff
#US PPI is the most important variable.

summary(cart2)

predictions <- predict(cart2)
actual_values <- trainset$Price  
# Calculate the squared differences between predictions and actual values
squared_differences <- (predictions - actual_values)^2
# Calculate the mean of the squared differences (Mean Squared Error)
mse <- mean(squared_differences)
# Calculate the RMSE (square root of MSE)
rmse.cart.train <- sqrt(mse)
rmse.cart.train


#Predicting Price on Test Dataset
pred <- predict(cart2, newdata = testset)
summary(pred)
rmse.cart.test<-sqrt(mean((pred-testset$Price)^2)) #(Predicted value-Actual Value)^2
rmse.cart.test 
#5.063708

rmse.cart.train
#3.808905
rmse.cart.test
#5.063708
