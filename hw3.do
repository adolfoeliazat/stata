clear all
cap log close
log using merge_reshape.log, text replace
set more off
cd "/Users/Sun/Desktop/Econometrics/stata/" 
 
import delimited using "caschool.csv"

sort id
by id: gen score_avg = (read_scr + math_scr)*(1/2)

gen TS = teachers/enrl_tot

//Part 1
regress score_avg TS

//b0: 611.1008
//p-value: 0.000
//b1: 837.5918
//p-value: 0.000
//r^2: 0.0512

//Part 2

gen logavginc = log(avginc)

regress score_avg TS logavginc

//b0: 542.9209
//p-value: 0.000
//b1:331.8505
//p-value: 0.000
//b2: 35.60788
//r^2: 0.5703

// prediction: (542.9209) + (331.8505)(0.05) + (35.60788)ln(20000) = 712.66 

//Part 3

regress TS logavginc

//alpha1: 0.0024463

//The estimate for b11 is greater than b12. 
//This is because in the first regression, we were only using TS as the explanatory variable of interest. 
//In the second regression, however, we had both TS and average income as explanatory variables.
//As the third regression shows, average income does have a positive relationship with TS (since alpha 1 > 0).
//Hence, when we regressed score avg on only TS, the b11 value was larger because it "contains" some of the impact of average income on TS as well.
//In the second regression,  the b12 value was smaller than before because average income was included in the regression, so b12 explained only the relationship of TS on score average.

//Part 5

predict TShat, xb

by id: gen residuals = TS - TShat 

regress score_avg residuals 

//Part 6 

//b13: 331.8505

//Intuition??


//Part 7

regress math_scr TS logavginc

//b0: 551.2738
//p-value: 0.000
//b1:231.1734
//p-value: 0.064
//b2: 34.09867
//r^2: 0.5299

regress math_scr TS logavginc read_scr

//b0: 118.7277
//p-value: 0.000
//b1: -118.8067
//p-value: 0.090
//b2: 4.065358
//p-value: 0.002
//b3: 0.8091507
//p-value: 0.000
//r^2: 0.8559

//Part 8: intuition?

//Part 9: intuition?

