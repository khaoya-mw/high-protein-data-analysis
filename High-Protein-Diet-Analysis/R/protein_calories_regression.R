#Loading packages
library(tidyverse)
library(ggplot2)

#reading dataset

hdci <- read_delim("healthy_diet_calorie_intake.csv",delim = ',',col_names = TRUE )

# Inspecting structure

colnames(hdci)
str(hdci)
summary(hdci)

#Changing column types
hdci$Gender <- as.factor(hdci$Gender)
hdci$Activity_Level <- as.factor(hdci$Activity_Level)
hdci$Diet_Type <- as.factor(hdci$Diet_Type)

# Creating a scatter plot of protein intake and calorie consumption for visualization
ggplot(hdci, aes(x = Protein_Intake_g, y = Daily_Calorie_Consumed)) + geom_point() + geom_smooth(method = "lm", se = FALSE)

correlation <- cor(hdci$Protein_Intake_g,hdci$Daily_Calorie_Consumed)
# It has a positive correlation of 0.469 , Which suggests a higher protein intake is associated with a 
# higher calorie consumption

# Model 1 - Does protein intake predict calorie consumption?
# Research question: Is higher protein intake associated with higher daily calorie 
# consumption after accounting for other factors

regression1 <- lm(Daily_Calorie_Consumed ~ Protein_Intake_g + Age + Gender + Activity_Level + Diet_Type, data = hdci)
summary(regression1)

#Interpretation
# The model explains 72.4% of the variation in calorie consumption (R^2 = 0.7241), and it is statistically significant because the p value is less than 2.2e-16
# An additional 1 gram of protein is associated with roughly 7.12 additional calories of daily calorie consumption
#Interesting to note, holding protein intake , age, gender, and activity level constant, the high protein diet category is associated with about 885 fewer calories than the balanced diet
#Furthermore the activity results are all statistically significant. It indicates strong differences in predicted calorie consumption
# across activity categories, even after controlling for other variables
# The age variable is consistent with the sql querry as each additional year of age is associated with approximately 3.55 fewer calories of daily calorie consumption
#In terms of gender the reference category is Female. Thus after controlling for other variables, the model predicts substantially higher calorie consumption
# for male and other participants compared with female participants.

# Thus in relation to the research question
# Protein intake has a strong positive association with daily calorie consumption in the multivariabe regression model 