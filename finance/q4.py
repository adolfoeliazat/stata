import math 

# data from EXCEL 

# the liability cash flows (in millions of dollars)
liabCashFlows = [0,
100,
120,
140,
160,
190,
200,
250,
270,
250,
290,
300,
310,
290,
280,
270,
250,
230,
230,
240,
250,
230,
200,
190,
180,
190,
170,
150,
150,
160,
130]

# the spot rates (in percents) for today
spotRatesPercentToday = [0,
0.95,
0.94,
0.95,
1.00,
1.07,
1.15,
1.24,
1.33,
1.41,
1.49,
1.56,
1.63,
1.69,
1.74,
1.79,
1.83,
1.87,
1.90,
1.94,
1.96,
1.99,
2.01,
2.03,
2.05,
2.07,
2.09,
2.10,
2.12,
2.13,
2.14]

# the spot rates (in percents) for scenario 1
spotRatesPercent1 = [0, 
1.45,
1.44,
1.45,
1.50,
1.57,
1.65,
1.74,
1.83,
1.91,
1.99,
2.06,
2.13,
2.19,
2.24,
2.29,
2.33,
2.37,
2.40,
2.44,
2.46,
2.49,
2.51,
2.53,
2.55,
2.57,
2.59,
2.60,
2.62,
2.63,
2.64]

# the spot rates (in percents) for scenario 2 
spotRatesPercent2 = [0,
2.34,
2.24,
2.17,
2.12,
2.08,
2.05,
2.03,
2.01,
2.00,
1.99,
1.98,
1.97,
1.97,
1.96,
1.96,
1.96,
1.95,
1.95,
1.95,
1.94,
1.94,
1.94,
1.94,
1.94,
1.94,
1.93,
1.93,
1.93,
1.93,
1.93]

def percentToDecimal(array): 

	result = [] 

	for elem in array: 
		result.append(elem / 100.0)

	return result 

# clean up the data (convert percents to decimals)
spotRatesToday = percentToDecimal(spotRatesPercentToday)
spotRates1 = percentToDecimal(spotRatesPercent1)
spotRates2 = percentToDecimal(spotRatesPercent2)

# get present value of bond (bond price)
def getPresentValue(cashflows, yields): 
	totalSum = 0 

	cashflowsLen = len(cashflows)
	yieldsLen = len(yields)

	if (cashflowsLen != yieldsLen): 
		print "getPresentValue: ERROR, inputs are not the same length"
	else: 
		# perform all the computations 
		# iterate through both arrays
		for i in range(cashflowsLen): 
			totalSum += (cashflows[i] * math.exp(-(yields[i] * i)))

		return totalSum 

# function to input yield rate and see what the resulting present value of the cashflows is
def getYield(cashflows, rate): 
	totalSum = 0 

	cashflowsLen = len(cashflows)

	# perform all the computations 
	# iterate through both arrays
	for i in range(cashflowsLen): 
		totalSum += (cashflows[i] * math.exp(-(rate * i)))

	return totalSum 

# find yield via trial and error using the function above
# see if the result = liabPresentVal1
# print getYield(liabCashFlows, 0.018189)
yieldRate = 0.018189

# get duration (of liability, bond, etc.) 
def getDuration(cashflows, rate, bondPrice): 
	totalSum = 0 

	cashflowsLen = len(cashflows)

	# convert bondPrice to a float just in case we need floating point division 
	bondPrice = bondPrice / 1.0 

	# perform all the computations (iterate through both arrays)
	for i in range(cashflowsLen):
		presentValue = (cashflows[i] * math.exp(-rate * i)) / bondPrice 
		totalSum += (i * presentValue)

	return totalSum 

# get convexity (of liability, bond, etc.)
def getConvexity(cashflows, rate, bondPrice): 
	totalSum = 0 

	cashflowsLen = len(cashflows)

	# convert bondPrice to a float in case we need floating point division
	bondPrice = bondPrice / 1.0

	for i in range(cashflowsLen): 
		totalSum += (cashflows[i] * (i * i) * math.exp(-rate * i))

	totalSum = totalSum / bondPrice 

	return totalSum 

# find the bond's future value
def getBondVal(investment, rate, years): 
	return (investment * (math.exp(rate * years)))

# find the bond's present value 
def getBondPresVal(facevalue, rate, years): 
	return (facevalue * (math.exp(-rate * years)))

# QUESTION 1: present value of liabilities with the current treasury rates 
liabPresentVal1 = getPresentValue(liabCashFlows, spotRatesToday)
print "Question 1:", liabPresentVal1

# QUESTION 2: duration of liabilites with the current treasury rates
liabDuration1 = getDuration(liabCashFlows, yieldRate, liabPresentVal1)
print "\nQuestion 2:", liabDuration1

# QUESTION 3: what are the values of the liabilities in the other 2 scenarios

liabPresentValScen1 = getPresentValue(liabCashFlows, spotRates1)
liabPresentValScen2 = getPresentValue(liabCashFlows, spotRates2)
print "\nQuestion 3 (scenario 1):", liabPresentValScen1
print "Question 3 (scenario 2):", liabPresentValScen2


# QUESTION 4:
L = getBondVal(liabPresentVal1, spotRatesToday[25], 25)
print "Face value: 1, year 0", L
bondVal1b = getBondPresVal(L, spotRates1[25], 25)
print "Present value: 1, year 1", bondVal1b
bondVal2b = getBondPresVal(L, spotRates2[25], 25)
print "Present value: 2, year 1", bondVal2b

netDiff1 = (bondVal1b - liabPresentVal1)
netDiff2 = (bondVal2b - liabPresentVal1)
print "\nQuestion 4 (scenario 1):", bondVal1b
print "Question 4 (scenario 2):", bondVal2b
print "Question 4 (difference 1):", netDiff1
print "Question 4 (difference 2):", netDiff2

# QUESTION 5: 

# They are not riskfree because the duration of the assets and the duration of the liabilities are different 
# From the textbook, we know that if the net duration (between assets and liabilities) != 0, 
# then we are NOT guarded against parallel shifts in the yield curve. 
# Risk = variance in net value 

# QUESTION 6: 

# duration of zero coupon bonds is their time to maturity 
# solve (x + y = 1), (10x + 15y = 14.1505219899) with Wolfram Alpha

# x = 0.169896 and y = 0.830104
dec10 = 0.169896
dec15 = 0.830104

fraction10 = dec10 * liabPresentVal1
fraction15 = dec15 * liabPresentVal1

print "\nQuestion 6 (10 year bond):", fraction10
print "Question 6 (15 year bond):", fraction15


# QUESTION 7: 

assets10 = getBondVal(fraction10, spotRatesToday[10], 10)
assets15 = getBondVal(fraction15, spotRatesToday[15], 15)

assetsScen1 = getBondPresVal(assets10, spotRates1[10], 10) + getBondPresVal(assets15, spotRates1[15], 15)
assetsScen2 = getBondPresVal(assets10, spotRates2[10], 10) + getBondPresVal(assets15, spotRates2[15], 15)

netDiff3 = (assetsScen1 - liabPresentVal1)
netDiff4 = (assetsScen2 - liabPresentVal1)

# similar approach to # 4 

print "\nQuestion 7 (scenario 1):", assetsScen1
print "Question 7 (scenario 2):", assetsScen2
print "Question 7 (difference 1):", netDiff3
print "Question 7 (difference 2):", netDiff4


# QUESTION 8a: 

# We see that the net values are smaller in the second case, especially in scenario 1 because we are 
# guarding against parallel shifts in the yield curve by setting the duration of liabilities and 
# the duration of assets equal. We still cannot protect against nonparallel shifts though. 


# QUESTION 8b: 
# convexity 
liabConvex = getConvexity(liabCashFlows, yieldRate, liabPresentVal1)
print "\nQuestion 8 (convexity):", liabConvex


# QUESTION 9: 
# convexity for zero coupon bonds -> t^2 

# solve 
# 5*x + 15*y + 25*z = 14.1505219899
# x + y + z = 1
# (5^2)*x + (15^2)*y + (25^2)*z = 257.356197448

# x = 0.331677 and y = 0.421595 and z = 0.246729

d5 = 0.331677
d15 = 0.421595
d25 = 0.246729

frac5 = d5 * liabPresentVal1
frac15 = d15 * liabPresentVal1
frac25 = d25 * liabPresentVal1

print "\nQuestion 9 (5 year bond)", frac5
print "Question 9 (15 year bond)", frac15
print "Question 9 (25 year bond)", frac25

# QUESTION 10 

at5 = getBondVal(frac5, spotRatesToday[5], 5)
at15 = getBondVal(frac15, spotRatesToday[15], 15)
at25 = getBondVal(frac25, spotRatesToday[25], 25)

atScen1 = getBondPresVal(at5, spotRates1[5], 5) + getBondPresVal(at15, spotRates1[15], 15) + getBondPresVal(at25, spotRates1[25], 25)

atScen2 = getBondPresVal(at5, spotRates2[5], 5) + getBondPresVal(at15, spotRates2[15], 15) + getBondPresVal(at25, spotRates2[25], 25)

netDiff5 = (atScen1 - liabPresentVal1)
netDiff6 = (atScen2 - liabPresentVal1)

print "\nQuestion 10 (scenario 1):", atScen1
print "Question 10 (scenario 2):", atScen2
print "Question 10 (difference 1):", netDiff5
print "Question 10 (difference 2):", netDiff6


# QUESTION 11 

# To guard against risk, you should diversify your portfolio for all the different time ranges, i.e., buy, 1 year ZCB, 
# 2 year ZCB, 3 year ZCB, ..., and 30 year ZCB

# We could apply the same method as above for these different bonds 




