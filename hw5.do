// Metrics PSET 5:

clear all
cap log close
log using merge_reshape.log, text replace
set more off
cd "/Users/Sun/Desktop/Econometrics/stata/" 
 
use "wage2.dta"

// CLEAN THE DATA to get consistent results!
drop if missing(brthord)


// --------------------------------- Part a --------------------------------
// a.	Education is likely correlated with the error term due to omitted variable bias. 
// That is, there could be other terms within epsilon_i, such as ability, that help explain 
// wage as well as education. 

regress wage educ exper tenure sibs
//  wage |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
// educ |    71.2122   6.757601    10.54   0.000     57.94859    84.47581
// exper |    13.1329   3.408595     3.85   0.000     6.442621    19.82319
// tenure |   7.684232   2.585755     2.97   0.003     2.608993    12.75947
// sibs |  -13.14209   5.757753    -2.28   0.023    -24.44322   -1.840947
// _cons |  -161.3513   119.1296    -1.35   0.176    -395.1752    72.47252


// --------------------------------- Part b --------------------------------// b.	Brthord and educ may be negatively correlated because, the more children a family 
// has to support, the less resources that family has to invest a lot in each child’s education. 
// Thus, if you are the youngest of a large family, your family may not have as many resources 
// to invest in your education (since they already had to invest in the education of all of 
// your older siblings). In addition, parents of multiple children may not be as able to 
// devote as much attention to the education of their youngest child (in comparison to 
// their eldest) because their attention is already divided between multiple children. 

// --------------------------------- Part c --------------------------------// c.	In order for brthord to be a good instrument for educ, it must be uncorrelated with 
// the error term. In addition, not only must it be correlated with educ but, in the case of 
// a multi-linear regression, it must also be able to explain educ “beyond” the other variables
// being controlled for in the regression.We believe it is reasonable to assume that brthord 
// and the error term are uncorrelated because the timing of your birth is usually not related 
// to other factors like ability. // In addition, as we have already discussed in part b, we believe that brthord and education 
// are correlated, since there appears to be a negative relationship between the two variables. 
// Nevertheless, we cannot confirm whether brthord is able to provide additional information 
// about educ that the other variables in the regression cannot, which is why we must run a 
// regression of educ on all of the control variables (including brthord) to verify this assumption. // --------------------------------- Part d --------------------------------

// Code:
regress educ brthord exper tenure sibs
**  brthord |  -.0995593 
** exper |   -.234355 
** tenure |   .0297347 
**  sibs |  -.1453998  
** _cons |   16.65823

// Explanation: As it can be noted, the coefficient for brthord is negative 
// (i.e non-zero), which demonstrates that the variable is able to explain x 
// “beyond” the other variables being controlled for in the regression. Thus, 
// this regression demonstrates that brthord is likely a good instrument for educ. 

// --------------------------------- Part e --------------------------------
// Code:
regress educ brthord 
** brthord |  -.2826441 
**  _cons |   14.14945

predict EducHat, xb
regress wage EducHat exper tenure sibs

** EducHat |   195.9461   106.4445 
** exper |   42.62263   25.36782
** tenure |   3.918763   4.220347
** sibs |   10.11143   20.72055
** _cons |   -2228.33   1764.429 
** Number of obs   =       852

// --------------------------------- Part f --------------------------------

// Code
ivregress 2sls wage (educ=brthord) exper tenure sibs
/*
 wage    |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
	educ |   195.9461   118.4057     1.65   0.098    -36.12484     428.017
   exper |   42.62261   28.21843     1.51   0.131    -12.68449    97.92971
  tenure |   3.918766    4.69459     0.83   0.404    -5.282462    13.11999
	sibs |   10.11142   23.04894     0.44   0.661    -35.06367     55.2865
   _cons |  -2228.329     1962.7    -1.14   0.256    -6075.149    1618.492
*/

// Explanation: Here we see that indeed the betas are almost identical, which is
// expected. Note that however, standard errors differ. In particular, for example
// educ coefficient is bigger by roughly 12.03 than that of EducHat.

// --------------------------------- Part g --------------------------------// Explanation: As it was previously mentioned, the SEs are different between 
// the two methods. In this case, the SEs that resulted from the IV regression 
// are the correct ones, as the ones reported under the 2SLS regression are too
// small. This is because, in 2SLS, you are regressing your response variable 
// on the predicted values of the first-stage regression. By using only the 
// predicted values, you are effectively underestimating the SEs because you 
// are not taking into account the error term from the first state regression. 


*** The End.
