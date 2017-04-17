** Housekeeping
clear all
cap log close
log using regression.log, text replace
set more off

// Main

import delimited using "~/Desktop/Econometrics/stata/caschool.csv"

// Problem 1
// There are (15 vars, 420 obs)
sort id
by id: egen score_avg = mean(read_scr + math_scr)
histogram score_avg

// Almost looks like normal?
sum score_avg

// Problem 3
// 420    1308.313     38.1067     1211.1     1413.5

// Formula: b1 = sum (xi - xn) yi/ sum (xi -xn)^2
egen teachers_avg = mean(teachers)
by id: gen rcov = (teachers - teachers_avg) * score_avg
by id: gen rvar = (teachers - teachers_avg)^2
// bh stands for "by hand"
egen bhcov  = sum(rcov)
list bhcov
// bhcov: -434624.3
egen bhvar  = sum(rvar)
list bhvar
// bhvar: 1.48e+07 
gen bhb1 = bhcov/bhvar
list bhb1
// bhb1: -.0293757 

regress score_avg teachers
// b1: -.0293754
// b0: 1312.105 

// b1: p value 0.003
// b0: p value 0.000
// R^2: 0.0210

// Problem 5
gen ts = teachers/enrl_tot
regress score_avg ts
// bo: 1222.202
// b1: 1675.184 
// R^2: 0.0512

// Problem 6
// We use this for prediction
local beta0_hat = _b[_cons]
local beta1_hat = _b[ts]
gen tmp1 = `beta0_hat' + `beta1_hat'*(25/500)
list tmp1
// A: 1305.961 
drop tmp1
gen tmp1 = `beta0_hat' + `beta1_hat'*(50/500)
list tmp1
// B: 1389.72
drop tmp1

// Problem 7
scatter score_avg avginc || lfit score_avg avginc

regress score_avg avginc
// b1: 3.757099 
// b0: 1250.767
// R^2: 0.5076

predict problem7, xb
by id: gen residuals = (score_avg - problem7)
scatter residuals avginc

// Problem 8
gen lavginc = log(avginc)
scatter score_avg lavginc || lfit score_avg lavginc
// b1:  72.83937
// b0: 1115.665 
// R-squared = 0.5625


predict problem8, xb
by id: gen residuals8 = (score_avg - problem8)
scatter residuals8 lavginc

** End

** save "~/Desktop/Econometrics/stata/intro_data", replace
clear
log close

