#This first chunk makes the treatment bottles:
bott <- 10 #number of bottles per strain
num <- 25 #number of mosquitoes per bottle
uno.mort.24 <- rbinom(n=bott, size=num, prob=.25) #simulate dead mosquitoes, given  number of bottles and mortality rate
dos.mort.24 <- rbinom(n=bott, size=num, prob=.5)  #again for dos strain
tres.mort.24 <- rbinom(n=bott, size=num, prob=.75) # again for tres strain
uno.mort.48 <- rbinom(n=bott, size=num, prob=.5)
dos.mort.48 <- rbinom(n=bott, size=num, prob=.75)
tres.mort.48 <- rbinom(n=bott, size=num, prob=.99)
uno.mort.72 <- rbinom(n=bott, size=num, prob=.75)
dos.mort.72 <- rbinom(n=bott, size=num, prob=.99)
tres.mort.72 <- rbinom(n=bott, size=num, prob=.99)
three.strain.mortality <- data.frame(  #make a data frame and create an object called "three.strain.mortality"
 bottle=rep(c(1:bott), times=3),  #repeat bottle numbers for each of three strains
 treatment=rep("treatment", times=bott*3),
 
 strain=c(rep("uno", times=bott), rep("dos", times=bott), rep("tres", times=bott)), #repeat strain names for each bottle set
 'dead hr 24'=c(uno.mort.24, dos.mort.24, tres.mort.24), #add the simulated dead mosquitoes as column "dead"
 'dead hr 48'=c(uno.mort.48, dos.mort.48, tres.mort.48),
 'dead hr 72'=c(uno.mort.72, dos.mort.72, tres.mort.72),
 total.mosquitoes=rep(25, times=bott*3)  #add our totals column
)

 #This chunk makes the control bottles:
three.strain.controls <- data.frame(
  bottle=rep(c(11:12), times=3),  #repeat bottle numbers for each of three strains
  treatment=rep("negative.control", times=6),
  strain=c(rep("uno", times=2), rep("dos", times=2), rep("tres", times=2)), #repeat strain names for each bottle set
  'dead hr 24'=c(0,1,0,1,0,2),  #add just a few control bottles with a few dead mosquitoes
  'dead hr 48'=c(0,1,0,1,0,2),
  'dead hr 72'=c(0,1,0,1,0,2),
  total.mosquitoes=rep(25, times=6)  #add our totals column
  )

 #combine the treatment and control bottles:
final.ex.dataset<-rbind(three.strain.controls, three.strain.mortality)
final.ex.dataset.sorted<-arrange(final.ex.dataset, group=strain, .by_group = TRUE) #arange by strain
write_csv(final.ex.dataset.sorted, file="three.strain.three.timepoints.csv") #write a csv file from three.strain.mortality object
