Bioassay Data Analysis Using R \#2 - Comparing Mortality Across Three Insect Strains.
================
Dan Hartman
2025-03-26

## Objectives
1.  Understand the basics of plotting with ggplot()
2.  Use an example dataset to fit a binomial regression model.
3.  Use the model to get some information back about our dataset.

Take a minute to familiarize yourself with the script for todays meetup. It's 
long, but most of that is text to explain what is going on. Going forward, 
there will be more code and few comments. I kept most of the information in
the script so that you don't have to toggle back and forth with an explanatory
document.

Also take a minute to look at the example dataset (three.strain.mortality.csv).
This represents three strains of insect, in a situation where you are testing
for differences in mortality. This would be with a single insecticide, and with
a uniform dose. I'm imagining bottle assays here (thus the bottle column).

## The Workflow
These data were simulated, meaning that I chose the mortality rates for each
strain, and used a function to artificially kill a proportion of mosquitoes
according to those rates. So, there is naturally a little bit of noise. This
dataset is what you will read in to R.

The next step is to fit a model to those simulated data. Think of this as
drawing a line through those data points, just as you would with a regular
linear regression. This model is better specified to data that we have,
which is binomial rather than normal or Gaussian.

Finally, we can get some inference from the model output concerning differences
in mortality rates between the strains. Using the parameters from the fitted
model, we can back-estimate the mortality rates and compare them to the ones
we specified when we simulated the data. In an experimental setting you won't
have the luxury of that prior information, of course. These comparisons will
serve as a sanity check, and to show that we did the right things in our code.