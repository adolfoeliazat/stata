/*
In this do file, we'll take a look at one of the most used (and hence misused)
applications of Stata: regression.

Greg will be covering the theory behind linear regression in class, and this
is indispensible. As we will see, Stata will let you run just about any regression
you want, but that doesn't mean doing so is a good idea. It remains YOUR
responsibility to ensure that the regression makes sense and to interpret the
results.
*/

**Housekeeping
clear all
cap log close
log using regression.log, text replace
set more off

/*
For this excerise we'll just use the example dataset that comes with Stata.
It's the "automatic" dataset, but it's also about automobiles. Cute.
*/
sysuse auto

/*
Just as good general practice, when you're working with a new dataset, use
describe and list to get a sense of what you're working with. Note the number
of observations: 74. It's not a very big dataset, but sufficient for an example.
Describing the data is also a good opportunity to see any variable labels, which
can let you know what a variable is even it has an abbreviated name.
*/
d
list if _n<=10

/*
Let's say we're interested in how a car's miles-per-gallon affects its price.
This is the model
price = beta0 + beta1*mpg + u

First, because this is just a relationship between two variables, we can just
plot it. It's good to remember that linear regression is fundamentally drawing
a line through a cloud of points that minimizes the distance between the line
and the points.
*/
scatter price mpg || lfit price mpg

/*
Hmm, the regression line slopes downwards. That means, in this dataset
when you look at cars that get one more mile per gallon, they tend to cost less
That's a strange result! Is it just statistical noise? A nice thing about Stata
is that it does your (simple) hypothesis tests for you, so let's jump into the
regression command proper. The following tells Stata to run a regression with
price as the dependent variable and mpg as the independent variable.
*/
reg price mpg

/*
This gives us a lot of output. Some of it you'll probably never use. A key thing
to look at every time is "Number of Obs" in the top right. This is the number of
observations Stata used in the regression. If you don't tell it otherwise, Stata
will attempt to use the entire dataset (as it did here). This might not be what
you want - and "Number of Obs" can be a good sanity check. It also gives you a sense
of how much statistical power you can expect to have in your t-tests. You can
also find your R^2 in the top right.

The bottom table gives the coefficient estimates. Stata always includes a constant
by default (you can take it out with the option 'noconstant'). It's a sensible thing
to have in most regressions but is rarely an object of interest. We can also see the
coefficient on mpg, and it's negative, as the scatter plot would have implied.

Now that you've run the regression, Stata has these coefficients saved in memory.
You can 'extract' them using macros, or using the 'predict' command. The first saves an
individual coefficient value in a scalar variable called a macro (they behave a
lot like a variable in R). The second takes your estimated coefficients and applies them
to your data. If your regression model is
y = beta0 + beta1*x + u
'predict' will return a new variable containing: beta0_hat + beta1_hat*x
*/
local beta0_hat = _b[_cons]
local beta1_hat = _b[mpg]
gen predict_with_macros = `beta0_hat' + `beta1_hat'*mpg

predict predict_with_command, xb

count if predict_with_macros!=predict_with_command


/*
The next columns tell you about a t-test of the hull hypothesis that each coefficient
is (individually) 0. As you can see, the t-test statistic is -4.5, and the p-value is
too small to even show, so this relationship is "statistically significant". But does
that mean it's "true"?

This may be a case where we've violated one of the key assumptions of OLS. Lots of
things other than mpg determine a car's price, but we're acting as if mpg is the only
thing and everything else is "error". If, for example, big cars are more expensive, AND big
carse get worse mpg, then our error is correlated with our independent variable. Let's
investigate.
*/
corr mpg weight
corr price weight

/*
We were right! More weight decreases mpg and increases price. We haven't gotten to
multiple regression in class (and it's important that you understand the matrix algebra
underlying it), but Stata makes it very easy to do multiple regression, so let's do a
regression of mpg on price, controlling for weight.
*/

reg price mpg weight

/*
So now the coefficient on mpg is still negative, but it's no longer statistically
significant. We might think based on this that people just don't much care about mpg
(it was the 70s after all), or maybe they do, and there's some other reason OLS isn't
working here. We're definitely not going to answer the question with this example
dataset.
*/

/*
Let's turn our attention to a different question. This one is going to be motivated
more by demonstrating some pitfalls of Stata regression than any question of real
interest. How is price correlated with "repair record"?
*/

reg price rep78

/*
The results indicate that repair record doesn't seem to matter that much. However,
3 things have gone wrong in this regression: First, we didn't control for weight.
If bigger cars have systematically worse repair records, that's a problem.
*/
reg price rep78 weight

/*
Good, now we can see that repair record has an effect when you condition on weight.
That is, people might be willing to trade off a good repair record for a larger car,
but if you hold fixed the size of the car, they prefer a better repair record.
*/

/*
Second, our N is now 69 rather than 74. We've lost 5 observations, and that's because these
observations have missing values for rep78. Whenever you run a regression, Stata
checks for missing values in each of the variables (dependent or independent) and
removes any observations where it finds missing values. This means your regression will
run, but it's now on a selected sample. You want to make sure this sample is not
systematically selected, because then it might be wrong (the canonical example is
studies involving wages - people who don't work don't have a wage, but if we remove
them from the regression, we're examining only the people who were offered a high
enough wage to work.) Here, we suspect the missing values might be random.
*/
list if missing(rep78)

/*
And indeed, there doesn't seem to be much of a pattern in the missing values.
If you're obsessively tidy about these sorts of things, you might prefer that
Stata not go around excluding observations from your regressions without explicitly
telling you. The only way to ensure that happens is to make sure you only give
Stata valid observations. One way to do this is to drop invalid observations.
This works, but it might put you in a tough spot if you ever want those observations
back. Another way is to explicitly mark what you want in your regression sample,
then condition on that variable when running regressions.
*/
gen reg_sample = !missing(rep78)
tab reg_sample
reg price rep78 weight if reg_sample==1

/*
Last, we didn't think carefully about what the values of rep78 mean. Unfortunately, we
don't have a good idea of what they mean because Stata doesn't tell us
anything about "repair record". But we can guess it's some subjective score of how
easily the car is repaired or how often it needs to be repaired. And based on our
regression, we can guess that higher values are better (or at least people are willing
to pay more for a car with a higher repair record).

But do we think that the difference between rep78==1 and rep78==2 is the same as
the difference between rep78==4 and rep78==5? Maybe, maybe not, but we definitely
told Stata we thought those two were the same. We asked it to estimate a single
coefficient for rep78, so ANY change in rep78 has the exact same effect on price.
Instead, we can think of rep78 as a categorical variable and let each value
have a different effect on price. We do this by making a set of binary (or "dummy")
variables. The dummy for rep78==1 has value 1 when rep78==1 and 0 everywhere else. etc.
(Note that there are more elegant ways to constuct a set of dummies like this, but
I'm doing it this way for clear exposition).
*/

gen rep_d_1 = rep78==1
gen rep_d_2 = rep78==2
gen rep_d_3 = rep78==3
gen rep_d_4 = rep78==4
gen rep_d_5 = rep78==5

list rep*

reg price rep_d_1 rep_d_2 rep_d_3 rep_d_4 rep_d_5 weight

/*
OK, that's weird. Now it seems like all but the highest repair value
has a negative effect on price. What did we do wrong? Check the sample
size. The missing observations are back. Even though rep78 is missing
for those 5 observations, the dummies are not. Specifically, they all
equal 0. Let's fix the problem by conditioning on our regression sample.
*/

sum rep_d* if missing(rep78)
reg price rep_d_1 rep_d_2 rep_d_3 rep_d_4 rep_d_5 weight if reg_sample==1

/*
So the signs of our results look sensible, but Stata has "omitted" one of
our dummies. This is because of colinearity (which Greg will talk about).
Intuitively, the problem is that if we added x to each of the coefficients
on our dummies, then subtracted x from the coefficient on our constant, this
would be an equally valid set of results. Once again, Stata has erred on the
side of showing us results rather than ensuring that they are sensible results.

It remains in our best interests to ensure that Stata is running precisely
the regression we ask for (remember what happened with the missing values?),
and here we have two options: remove the constant or remove one of the dummies.
In general, we like to remove one of the dummies. This defines an "omitted category"
that we can use as the basis for comparison.
*/

reg price rep_d_2 rep_d_3 rep_d_4 rep_d_5 weight if reg_sample==1

/*
So now we can confidently say things like "Going from repair record 1 to
repair record 3 increases the price by $1379". We can also see that treating
rep78 as a categorical variable was a wise choice. The price increase between
2 and 3 (about $500) is very different from the price increase between 4
and 5 (about $1200). People sort of like a good repair record, but at least
some are willing to pay much more for the best repair record.
*/

/*
I encourage you to look through Stata's online documentation for
'regress'. It includes a lot more than discussed here, like weights
(for GLS) and robust standard errors (for heterosketasticity), both topics
we'll discuss later in the class.

And lastly, a note of caution. Regression (and extensions thereof) is a
powerful tool and remains the workhorse of empirical economics. However,
do not expect to convince anybody of anthing by simply running a bunch
of regressions. The best empirical work carefully justifies why it has
not fallen into any of the traps Greg will discuss in class, then runs
just one or two well-thought-out regressions. It's the first part that's
hard.
*/
