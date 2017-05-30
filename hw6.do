clear all
cap log close
log using merge_reshape.log, text replace
set more off
cd "/Users/Sun/Desktop/Econometrics/stata/" 
 
use "Airbnb_LA.dta"

drop if availability_30 == 0
// (33,255 observations deleted)

gen revenue = price*(30-availability_30)

*Question 1

regress revenue bedrooms bathrooms review_scores_rating
/*

      Source |       SS           df       MS      Number of obs   =   123,092
-------------+----------------------------------   F(3, 123088)    =  10426.04
       Model |  1.8647e+11         3  6.2155e+10   Prob > F        =    0.0000
    Residual |  7.3379e+11   123,088  5961531.67   R-squared       =    0.2026
-------------+----------------------------------   Adj R-squared   =    0.2026
       Total |  9.2026e+11   123,091  7476245.39   Root MSE        =    2441.6

------------------------------------------------------------------------------
     revenue |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    bedrooms |   1036.167   10.00445   103.57   0.000     1016.559    1055.776
   bathrooms |   460.7609   12.48602    36.90   0.000     436.2885    485.2333
review_sco~g |   27.25419    .869418    31.35   0.000     25.55014    28.95823
       _cons |  -2548.477   82.91647   -30.74   0.000    -2710.992   -2385.962
------------------------------------------------------------------------------
*/

*Interpretation: all of the coeff are positive, with bedrooms being the highest.
This makes sense because the more bedrooms that a living space contains, the more people you can host (so the higher the revenue).

*Question 2

 regress revenue bedrooms bathrooms review_scores_rating i.zipcode
/*
      Source |       SS           df       MS      Number of obs   =   123,092
-------------+----------------------------------   F(302, 122789)  =    141.66
       Model |  2.3778e+11       302   787350430   Prob > F        =    0.0000
    Residual |  6.8248e+11   122,789  5558141.95   R-squared       =    0.2584
-------------+----------------------------------   Adj R-squared   =    0.2566
       Total |  9.2026e+11   123,091  7476245.39   Root MSE        =    2357.6

------------------------------------------------------------------------------
     revenue |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    bedrooms |   1014.699   9.902994   102.46   0.000     995.2893    1034.109
   bathrooms |   463.2557   12.37204    37.44   0.000     439.0067    487.5047
review_sco~g |   23.72597   .8577334    27.66   0.000     22.04483    25.40712
             |
     zipcode |
      20855  |   531.5194   3334.153     0.16   0.873    -6003.365    7066.404
      46008  |  -287.6259   3334.135    -0.09   0.931    -6822.474    6247.223
      89104  |   1316.301   3334.124     0.39   0.693    -5218.526    7851.128
      90001  |   1730.676   2546.471     0.68   0.497    -3260.366    6721.717
      90002  |   1515.581   2546.571     0.60   0.552    -3475.656    6506.818
      90003  |   614.6346   2418.853     0.25   0.799    -4126.277    5355.547
      90004  |   1150.313   2358.461     0.49   0.626    -3472.231    5772.858
      90005  |    1221.91   2358.849     0.52   0.604    -3401.394    5845.213
      90006  |   617.2773   2358.652     0.26   0.794    -4005.641    5240.195
      90007  |   640.7231   2359.584     0.27   0.786    -3984.022    5265.468
      90008  |   880.3479   2363.054     0.37   0.709    -3751.198    5511.894
      90010  |   1720.378   2363.305     0.73   0.467    -2911.661    6352.416
      90011  |   616.9375   2378.922     0.26   0.795    -4045.711    5279.586
      90012  |   1653.451   2358.708     0.70   0.483    -2969.577     6276.48
      90013  |   1568.554   2359.268     0.66   0.506    -3055.573    6192.681
      90014  |   1841.833   2359.063     0.78   0.435    -2781.892    6465.557
      90015  |   2030.374   2358.666     0.86   0.389    -2592.572    6653.319
      90016  |   1129.838    2359.94     0.48   0.632    -3495.604     5755.28
      90017  |   2211.229   2358.409     0.94   0.348    -2411.213    6833.671
*/

Interpretation: doesn't change results that much. It slightly decreases the coeff, perhaps because it removes the omitted variable bias of zip code/locations.

*Question 3:

We could randomly assign good and bad reviews to each listing.

*Question 4:

The regression from part 1 doesn't help us estimate this because it does not take into account the omitted variable bias of quality on reviews.
Since it doesn't control for quality, it will not inform about the impact of just the reviews (separate from quality) on revenue.
The panel data structure can help estimate this because quality is something that you can assume is constant over time, so you can "control" for it by effectively subtracting from the regression.
This, in theory, will imply that the coefficient of reviews will only contain the effect of the reviews (without taking quality into account). 

*Question 5:

You would want to consider including property in the regression in order to control for quality (assuming that it remains fairly constant for each listing over time).
You would also want to include scrap-time to account for the change in value of certain regions over time (i.e the demand for certain places increases during summer months, so revenue will be higher).  

*Question 6:

areg revenue review_scores_rating i.last_scrape, absorb(id)
/*
Linear regression, absorbing indicators         Number of obs     =    123,092
                                                F(  20,  88299)   =     262.91
                                                Prob > F          =     0.0000
                                                R-squared         =     0.7049
                                                Adj R-squared     =     0.5886
                                                Root MSE          =  1753.8486

------------------------------------------------------------------------------
     revenue |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
review_sco~g |     6.4205    1.91086     3.36   0.001     2.675231    10.16577
             |
 last_scrape |
      20233  |  -31.28894   55.23758    -0.57   0.571    -139.5541    76.97621
      20294  |   763.0706   174.2336     4.38   0.000     421.5743    1104.567
      20295  |   785.6707   124.0715     6.33   0.000     542.4918     1028.85
      20296  |   699.9267    69.9684    10.00   0.000     562.7892    837.0641
      20297  |   660.7046   54.63514    12.09   0.000     553.6203     767.789
      20298  |   718.4914   64.83526    11.08   0.000     591.4149     845.568
      20333  |  -116.8028   56.38389    -2.07   0.038    -227.3147   -6.290891
      20334  |  -188.8718   53.49328    -3.53   0.000    -293.7182    -84.0255
      20398  |  -475.0234   50.72322    -9.37   0.000    -574.4405   -375.6064
      20399  |   331.1655   1860.719     0.18   0.859    -3315.827    3978.158
      20455  |  -383.8505   139.5589    -2.75   0.006    -657.3847   -110.3163
      20456  |  -493.1518   50.84943    -9.70   0.000    -592.8162   -393.4874
      20576  |  -214.2881   50.77385    -4.22   0.000    -313.8044   -114.7718
--more--
*/
/*
Interpretation: The coeff is now much lower than it was in part 1 (6.4 vs. 27.3), which makes sense, since we are now trying to control for quality (unlike in part 1). 
Thus, we would expect that the relationship between reviews (without the effect of quality) will be smaller. 
The variation that we are exploring in the data is the fact that review scores change over the times that the data was recorded.
By controlling for property id and last_scrap, we can take out their effects on the change in review scores (so only the effect of change in review on revenue is taken into account). 
*/
**Question 7:

/*
In order to interpret the result from part 5 as causal, we need to ensure that the review scores are uncorrelated with the error term. 
More specifically, we need the cov(review_scores_rating, eit) = 0. 
This way, you can at least ensure that the coefficient that you get from the regression depicts only the effect or reviews on revenue (and does not contain the effects of other variables). 
*/
