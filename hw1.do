/*
 ~ Set up ~
*/
clear all
cap log close
log using "~/Desktop/Econometrics/stata/hw1.log", text replace
set more off

/*
 ~ Main ~
*/
foreach x in 5 10 25 50 100 250 500 {
	di "Current sample size = " `x'
	// CHANGE n = 5 obersvations to maybe 10?
	set obs `x'
	// Let `id` be the indicator of the step (2) counter.
	gen id = _n
	// CHANGE S = 10 to 1000.
	expand 1000
	sort id

	// Generate uniform data
	set seed 5142017
	by id: gen s = runiform()

	// Now let's calculate statistics
	by id: egen p_s_ave = mean(s)
	replace p_s_ave = 2*p_s_ave

	by id: egen p_s_max = max(s)

	// Note that `g` prefix stands for `global`
	// For average:
	egen gmu_ave = mean(p_s_ave)
	gen gsigma_ave_tmp = (p_s_ave - 1)^2
	egen gsigma_ave = mean(gsigma_ave_tmp)
	drop gsigma_ave_tmp

	// For maximum:
	egen gmu_max = mean(p_s_max)
	gen gsigma_max_tmp = (p_s_max - 1)^2
	egen gsigma_max = mean(gsigma_max_tmp)
	drop gsigma_max_tmp

	di "gmu_av e" gmu_ave
	di "gsigma_ave " gsigma_ave
	di "gmu_max " gmu_max
	di "gsigma_max " gsigma_max
	di "_________________________"
	drop _all
}

/*
 ~ Clean up ~
*/
// line gmu_ave gmu_max id, title("Deviations for Worker 1") xtitle("Sample Size") ytitle("mu")
// save "~/Desktop/Econometrics/stata/hw1", replace
clear
log close
