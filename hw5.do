clear all
cap log close
log using merge_reshape.log, text replace
set more off
cd "/Users/Sun/Desktop/Econometrics/stata/" 
 
import delimited using "wage2.dta"

drop if missing(brthord)

// Part (d)
regress educ brthord exper tenure sibs
**  brthord |  -.0995593 
** exper |   -.234355 
** tenure |   .0297347 
**  sibs |  -.1453998  
** _cons |   16.65823
// YAY helps us explain the relevance condition.


// Part (e)
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

// Part (f)
ivregress 2sls wage (educ=brthord) exper tenure sibs
** educ |   195.9461   118.4057 
** exper |   42.62261   28.21843 
** tenure |   3.918766    4.69459 
** sibs |   10.11142   23.04894 
** _cons |  -2228.329     1962.7


*** The End.
