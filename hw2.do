**Housekeeping
clear all
cap log close
cd "\\itsnas\udesk\users\emilyding\Documents\"
log using "hw2.log", text replace
set more off

// Main

//--------------------------------- Problem 1 --------------------------------
import delimited using "caschool.csv"
// Problem 1: There are (15 vars, 420 obs)


//--------------------------------- Problem 2 --------------------------------
sort id
by id: gen score_avg = (read_scr + math_scr)*(1/2)

//--------------------------------- Problem 3 --------------------------------
histogram score_avg
sum score_avg
// observations: 420    mean: 654.1565     std. dev. 19.05335     min. 605.55     
// max 706.75


//--------------------------------- Problem 4 --------------------------------
// bh stands for "by hand"

// 4a) Covariance Formula: cov = sum (xi - xn) yi
egen teachers_avg = mean(teachers)
by id: gen rcov = (teachers - teachers_avg) * score_avg
by id: gen rvar = (teachers - teachers_avg)^2
egen bhcov  = sum(rcov)
list bhcov
// bhcov: -217312.2 

// 4a) Variance Formula: var = sum (xi -xn)^2
egen bhvar  = sum(rvar)
list bhvar
// bhvar: 1.48e+07 

// 4a) Beta 1 Formula: b1 = sum (xi - xn) yi/ sum (xi -xn)^2
gen bhb1 = bhcov/bhvar
list bhb1
// bhb1: -.0146878

// 4b) Regression
regress score_avg teachers 

// 4c) B0
// b0:  656.0523 
// b0: p value 0.000
// Interpret: Yes it is significantly different from zero, since the p-value 
// is 0.000, which is smaller than 0.05. In this context, b0 represents what 
// the score average of the school would be if there were no teachers.

// 4d) B1
// b1: -.0146877
// b1: p value 0.003
// Interpret: Yes, it is also significantly different from zero, since the 
// p-value is extremely small (0.003). Hence, it is much smaller than 0.05. 
// Here, b1 represents how much the score average of a school would decrease by 
// in response to a one unit increase in number of teachers.

// 4e) R^2
// R^2: 0.0210 
// e: R^2 is 0.0210, meaning that only 2.1% of the variation in score averages
// can be explained by changes in the number of teachers in each school.

//--------------------------------- Problem 5 --------------------------------
gen ts = teachers/enrl_tot
regress score_avg ts
// bo:  611.1008
// b1:  837.5918
// R^2: 0.0512

// 5c) Here, b1 is positive (unlike in problem 4). This makes sense because as 
// the ratio of teachers to students increases in a given school, presumably 
// the quality of education will increase as well, since each teacher will be 
// able to provide more individualized attention to students when the class 
// sizes are smaller. This improvement in education quality should, in theory, 
// translate to higher score averages. In the previous problem, we were only 
// regressing the number of teachers with score averages, which gave us a 
// negative slope for the best-fit line. This result doesn’t necessarily imply 
// that the more teachers a school has, the lower its average test scores will 
// be. Instead, the relationship between the number of teachers and score 
// average can be explained by other lurking variables, such as classroom size. 
// Often times, larger schools tend with more teachers also have more students, 
// meaning that the teacher student ratios can be quite large. In this scenario,
// students are likely to get less individualized attention from teachers, thus 
// decreasing the quality of education that they receive and their average test 
// scores.


// 5d) We prefer using the specification in question 5, since the teacher 
// to student ratio more accurately conveys how it is the quality of education 
// (among other external factors) that each student receives that affects the 
// average test scores (and not the absolute number of teachers per se).


//--------------------------------- Problem 6 --------------------------------
// 6a) Predicting Average Acores
local beta0_hat = _b[_cons]
local beta1_hat = _b[ts]
gen tmp1 = `beta0_hat' + `beta1_hat'*(25/500)
list tmp1 
// District A:  652.9804 
drop tmp1
gen tmp1 = `beta0_hat' + `beta1_hat'*(50/500)
list tmp1
// District B:  694.86 
drop tmp1

// 6b) We do not completely agree with this claim. While increasing the number 
// of teachers will increase the average test scores of school A, we can’t 
// claim that the new scores will match those of school B. This is because 
// there are other variables included in the error term of the regression that 
// affect student performance (such as school resources, quality of the students 
// themselves, parents’ investment in child education, and so on). Thus, 
// increasing the number of teachers to match that of school B will not 
// guarantee that the students in school A will have the same test performance.


// 6c) This could be possible because both the teacher student ratio and the 
// average test scores can be influenced by the same lurking/omitted variable 
// without having a causal impact upon each other, such as school size and 
// funding. A public school could be both small (which would increase the 
// teacher student ratio due to the smaller class sizes) and have a lot of 
// funding (thus providing more resources for its students and helping improve 
// their test performance).


//--------------------------------- Problem 7 --------------------------------
// 7a) Avinc
scatter score_avg avginc || lfit score_avg avginc

// 7b) No, the scatterplot shows a more curved pattern.

// 7c) Regress
regress score_avg avginc
// b1:  1.87855
// b0: 625.3836
// R^2:  0.5064

// 7d) Graph
predict problem7, xb
by id: gen residuals = (score_avg - problem7)
scatter residuals avginc

//--------------------------------- Problem 8 --------------------------------
//8a) Scatter Plot
gen lavginc = log(avginc)
scatter score_avg lavginc || lfit score_avg lavginc

// 8b) 
regress score_avg lavginc
// b1: 36.41968
// b0: 557.8323 
// R-squared = 0.5615

// 8c)
predict problem8, xb
by id: gen residuals8 = (score_avg - problem8)
scatter residuals8 lavginc

// 8d)
// In this question, the data points appear to display a much more linear 
// relationship than in question 7. This is confirmed by the fact that the 
// residual plot in part 8c displays a random scatter of residuals both above 
// and below the zero line, while the one in 7d shows residuals points that 
// are aligned in a more curved pattern about the zero line.  This can be 
// explained by the fact that the logarithmic transformation of the data points 
// in question 8 linearizes the data points.



//----------------------------------------------------------------------------

save "hw2save", replace
clear
log close

