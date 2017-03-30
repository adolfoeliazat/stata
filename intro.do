/*
Hello and Welcome to Stata!
This is not going to be a conventional introduction.
Instead, we will focus on the commands and ideas you will need to get through
the first homework. I explain what is going on with each command with detailed
comments, but I nevertheless encourage you to look each one up in the Stata
documentation to understand its syntax and powers. 
*/

/*
First, a note on how to access Stata. Stata is not generally free. If you would
like to run Stata on your personal computer, they offer discounted/short-term
licenses: http://www.stata.com/order/new/edu/gradplans/student-pricing/
(Note that "Small Stata" will almost certainly be too small for this class). 

Alternatively, you can access Stata (along with Matlab and a bunch of other 
useful programs) using vlab: http://academictech.uchicago.edu/vlab
Note that to do this, you must be on the university's network (as in, physically
on campus). This is what I'll be using to demonstrate Stata.
*/

/*
Let's start writing our do file. Stata lets you input commands individually
at the command line, and this is very useful for exploring a dataset, but if
we want to run the same sequence of commands every time (a program), we put them
all in a do file and execute it by typing 'do [name of file]'.
*/

/*
To begin, some lines of housekeeping I put at the top of just about 
every do file. They ensure that any datasets or log files that were 
active when I began the program are closed. Then they open a new log file and 
set the "more" option off, which basically means the screen will progress 
without further input from me. 
*/
clear all
cap log close
log using stata_intro.log, text replace
set more off

/*
Ordinarily, the next step would be to read in a dataset, but seeing as your 
homework calls for simulating data, we'll simulate a dataset here too. 
Let's make a dataset that follows some workers over time and records their
wage each year. To keep things managable, let's say we observe 10 workers from
ages 31 to 35. 
*/

/*
Start by using set obs to make one observation per worker. 
*/

set obs 10

/*
Now our dataset has 10 observations, but there's no data in any of them. We can 
see this using 'd', which is short for 'describe'.
*/
d

/*
Let's give each observation a worker ID. We're going to refer to Stata's
internal index using '_n'. The observation that has _n==1 is the first
observation in the dataset. If you were to look at the data, it would appear at
the top. The observation with _n==_N would instead appear at the bottom. We'll
use this to (gen)erate a variable that has the same value as Stata's internal 
index.
*/

gen id = _n

/*
Now list the data to see that each worker has a unique ID.
*/

list

/*
Now let's add a time dimension. We'll use the the 'expand' command, which
takes each observation in the dataset and copies it the number of times you tell
it to.
*/
expand 5

/*
We can see that we now have 5 observations for each ID using the (tab)ulate
command.
*/
tab id

/*
Now we need to assign ages to the observation. It's going to take a little more
tech than before. First we will 'sort' the data by id. This will put the
observation with the lowest value of id at the top, and with the highest value
at the bottom. Then we will perform a command 'by' id. This is a very neat
tool that essentially tells Stata to consider the observations associated with
each value of id as a different dataset, and perform the command in each one
individually. This extends to Stata's internal index, so we can use the same
trick as before to give each observation an age. 
*/
sort id
by id: gen age = _n

/*
Let's look at the data to make sure it worked.
*/
list

/*
It only kinda worked. 1-5 are not realistic ages for people in the labor market.
Let's fix that by replacing the value in the age variable.
*/
replace age = age + 30

/*
Let's (sum)mmarize the age variable to check that the ages in our dataset line 
up with our expectations.
*/
sum age
	
/*
OK, so now we have the skeleton of our dataset, but we still need wages!
Collecting that would be hard, so let's just use a random number generator. The
function rnormal() will draw from the standard normal distribution (mean 0,
standard deviation 1). Before we do anything random though, let's set the seed
of the random number generator so every time we run this program, we get
the same random draws.
*/
set seed 5142017
gen wage = rnormal()	

/*
Now that looks like a proper dataset. (Well, except for all the negative wages,
but just go with it).
*/
list

/*
Next, let's analyze our data. Maybe we want to know how far each wage observation
is from the average wage in the dataset. For that, we'll use 'egen', which is a
very powerful command that lets you calculate simple things like averages, 
standard deviations, maxima, minima, etc. and store them as new variables in our
dataset. 
*/
egen average_wage = mean(wage)
gen wage_deviation = wage - average_wage
list

/*
Maybe we're more interested in how far each wage observation is from the average
for that worker. The good news is that 'egen' plays nicely with 'by'. 
*/
by id: egen worker_average_wage = mean(wage)
gen worker_wage_deviation = wage - worker_average_wage

/*
Let's list the data, but  now just look at the variables that are relevant to 
this question.
*/
list id age wage worker_*

/*
In fact, the comparison to the average wage wasn't that interesting after all
(the average is close to 0 by construction), so let's just drop those variables.
*/
drop average_wage wage_deviation

/*
Of course, none of this is any good if we can't show others our results. Stata's
graphing utilities are extremely large and complicated, but the below
demonstrates how to make a basic line graph with titles. (Remember, y-axis
first, x-axis second)
*/
line worker_wage_deviation age if id==1, title("Deviations for Worker 1") xtitle("Age") ytitle("Deviation from Mean")

/*
'drop' can actually be used in two ways. The first one is the way I used it above
to drop VARIABLES you no longer need. If instead you combine it with a 
conditional statement, you will drop all OBSERVATIONS meeting those criteria.
Let's say we get a call from the people who gathered the data, and they tell us
the data from worker 8 is total junk. Let's get rid of it.
*/
drop if id==8
tab id

/*
The inverse of 'drop' is 'keep'. Let's say we discover only the data from 
age==32 is valid. We can keep just those data.
*/
keep if age==32
list

/*
Another important thing to note lest you get confused. '=' is different from 
'=='. The first one is assignment. It assigns the value on the right hand
side to the variable on the left hand side. The second is a test for equality.
It returns 1 if the values on both sides are identical and 0 otherwise. Other 
conditional statements (>, <, <=, >=) work the same way. Let's say we want to
mark all the observations that are more than 1/2 above the worker mean. 
*/
gen big_deviation = (worker_wage_deviation>0.5)
list

/*
Lastly, we're done with our data for now, so let's save it (even though
we've kind of shredded it to pieces) and clear the workspace.
*/
save intro_data, replace
clear
log close

/*
So that's an intro to Stata. This example program demonstrates all the commands
I needed (and a few I didn't) to write the model solution for the homework. 
Importantly, unless you want to loop over all values of N in a single run of 
your program, you DO NOT need macros, though I will accept solutions that use 
them. 

If you're interested in using Stata for anything outside this class (you will
probably encounter it if you do any RA work), I encourage you to get comfortable
with using the descriptive commands (describe, list, tabulate, summarize) to 
explore and understand a dataset. It's much faster and more flexible than the
visual data editor. 
*/


