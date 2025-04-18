rm(list=ls())
library(tidyverse)
library(emmeans)
#setwd("C:/Users/hartm/OneDrive/Documents/bioassay_analysis_workshop/Meeting_2")
setwd("") # set your working directory to the folder containing this script and the
  #example dataset.

####  I included a sample data set - this is how I made it.
####  These next lines simulate data for three mosquito strains 
####  with different mortality rates.  Use the ?function() to see what these
####  functions do, or make a different data set (increase sample sizes, etc.).
####  Strains are named uno, dos, and tres. 
#### uncomment (delete first # of each line) to run

# This first chunk makes the treatment bottles:
# bott <- 10 #number of bottles per strain
# num <- 25 #number of mosquitoes per bottle
# uno.mort <- rbinom(n=bott, size=num, prob=.25) #simulate dead mosquitoes, given  number of bottles and mortality rate
# dos.mort <- rbinom(n=bott, size=num, prob=.5)  #again for dos strain
# tres.mort <- rbinom(n=bott, size=num, prob=.75) # again for tres strain
# three.strain.mortality <- data.frame(  #make a data frame and create an object called "three.strain.mortality"
#  bottle=rep(c(1:bott), times=3),  #repeat bottle numbers for each of three strains
#  treatment=rep("treatment", times=bott*3),
#  strain=c(rep("uno", times=bott), rep("dos", times=bott), rep("tres", times=bott)), #repeat strain names for each bottle set
#  dead=c(uno.mort, dos.mort, tres.mort), #add the simulated dead mosquitoes as column "dead"
#  total.mosquitoes=rep(25, times=bott*3)  #add our totals column
# )
# 
#  #This chunk makes the control bottles:
# three.strain.controls <- data.frame(
#   bottle=rep(c(11:12), times=3),  #repeat bottle numbers for each of three strains
#   treatment=rep("negative.control", times=6),
#   strain=c(rep("uno", times=2), rep("dos", times=2), rep("tres", times=2)), #repeat strain names for each bottle set
#   dead=c(0,1,0,1,0,2),  #add just a few control bottles with a few dead mosquitoes
#   total.mosquitoes=rep(25, times=6)  #add our totals column
#   )
# 
#  #combine the treatment and control bottles:
# final.ex.dataset<-rbind(three.strain.controls, three.strain.mortality)
# final.ex.dataset.sorted<-arrange(final.ex.dataset, group=strain, .by_group = TRUE) #arange by strain
# write_csv(final.ex.dataset.sorted, file="three.strain.mortality.csv") #write a csv file from three.strain.mortality object

#####################################################
#####################################################
#############   Start Here! #########################
#####################################################
 
data <- read_csv("three.strain.mortality.csv")
str(data) #This time we have double integers as well as character columns
head(data) #Look at the top few rows of the table

#  Here is a data cleaning step:
unique(data$strain) #get the unique values for each strain
unique(data$treatment) #get unique bottle types
#  If we have any typose in the sheet we will see them here and correct them
#  before going any further

#  What are we missing?  Mortality rates of course!  Lets calculate those.
data<-mutate(data, mort.rate=dead/total.mosquitoes) #we are overwriting the "data" dataframe
#  Mutate can add a column calculated from other columns.
head(data)

#  How to look at only negative controls? This is called subsetting, or filtering. 
#  Great data exploration tool.
#  There are ways with base R, but tidyverse makes this a lot easier for us.
filter(data, treatment=="negative.control") #notice the double =.  this is necessary for logical equations.
#  Great, low mortality in control bottles.  Not bad!

#  An equivalent way of filtering for negative control bottles:
data %>% filter(treatment=="negative.control")
#   The %>% takes the data and passes it through one or several steps of manipulation

#  We can also have multiple filterin criteria:
data %>% filter(treatment=="negative.control", strain=="dos")

#  Let's make a quick plot of the negative control bottles using base R
neg.bottles<-data %>% filter(treatment=="negative.control")
plot(y=neg.bottles$mort.rate, x=as.factor(neg.bottles$strain))
#  It works, but I don't like it.  Let's get some better plotting going with ggplot.
#  ggplot graphics package loads automatically with tidyverse, so we are good to go.

ggplot(data=data) +
  geom_point(aes(x=strain, y=mort.rate))

# That's cool, but how do we distinguish between treated and negative control bottles?

ggplot(data=data) +
  geom_point(aes(x=strain, y=mort.rate, color=treatment))

# better - but it's best practice to use symbols in addition to colors, in case
# this gets printed in black and white, or for colorblind folks. And, our axes
# come from the column names - so let's fix those axis labels. And a different
# theme/aesthetic
ggplot(data=data) +
  geom_point(aes(x=strain, y=mort.rate, color=treatment, shape = treatment)) +
  ylab("Mortality Rate in Bottles") +
  xlab("Mosquito Strain") +
  theme_bw()
# Nice, clean, and readable :)

#  It looks like we might have some differences in mortality rates. Who knew :)
#  We are ready for our hypothesis test. We can use a binomial regression for this.

#  Our negative control bottles won't go into this, so we can filter them out.
#  They were mostly there in order to make sure our assays went well, and that 
#  We didn't need to make a correction.

glm(mort.rate ~ strain, #Formula - analyze number of dead mosquitoes as a function of strain
  weights = total.mosquitoes, #The total number of mosquitoes in each bottle (in case they differed)
  data=data %>% filter(treatment=="treatment"), #specify dataset and remove neg. control bottles
  family=binomial)

#  If this is all we do, the function gives output for the fitted coefficients and intercept.
#  Let's create an object, to make some other stuff easier.

model.fit <- glm(mort.rate ~ strain, #Formula - analyze number of dead mosquitoes as a function of strain
    weights = total.mosquitoes, #The total number of mosquitoes in each bottle (in case they differed)
    data=data %>% filter(treatment=="treatment"), #specify dataset and remove neg. control bottles
    family=binomial)

# We can make some handy plots to see how well our model fit.  Yours will never look
# this nice, be forwarned!  We simulated this data, so it's pretty synthetic, and if 
# these didn't look nice I'd really worry that we chose the wrong type of model. Enter
# this, then hit enter to keep seeing additional plots. I usually focus on the Q-Q plot
# and the residual plot.
plot(model.fit)

# This will give you a summary of your model, and some p-values - these can use
# different tests by default, depending on the type of model. See ?summary.glm()
summary(model.fit)


#  Great - we have data (points), and then fit a line through those points (our model)
#  These coefficients and intercept describe that line.
model.fit
#  Why do we only have coefficients for two of our strains? The short answer is,
#  the model uses one factor as "reference" factor, fixing it at 0. Check the signs
#   - the positive coefficient for "tres" means that tres has higher mortality
#  Than the reference factor (dos, chosen automatically). Coefficient "uno" has a
#  Negative sign, meaning that it has lower mortality than dos.  We can think of
#  The intercept as the reference strain here (dos).

#  So with these values, we get some predictive power. We can use this handy function
#  to back-calculate the predicted means for each strain, using the intercept and 
#  coefficients from our model:
emmeans(model.fit, ~ ".", 
        type="response", 
        weights = data$total.mosquitoes,
        adjust=TRUE)
#  We simulated these data with each strain having a different mortality rate.
#  Those were uno-0.25, dos-0.50, tres-0.75.  Compare those with the output of
#  emmeans (prob column).  Look at the lower and upper confidence limits to see
#  What our margin of error is.  Not bad for just 10 treatment bottles in each group.
#  We can treat non-overlap of these confidence intervals as our hypothesis test.

#  When your experimental design gets a bit more complex, multiple doses, observation
#  periods, etc. - we can use predict() to get estimates of mortality from specific
#  sets of conditions.  I'll save that for when we do LC50's.