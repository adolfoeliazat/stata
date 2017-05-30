# by Malika Aubakirova

import csv 
import numpy as np
filename = "Excess_returns.csv"

f = open(filename, 'rU')
reader = csv.reader(f, dialect=csv.excel_tab)
means = [0.0] * 4
portfolios = [[], [], [], []]
rows = []

for x in reader:
    row = x[0].split(",")
    if row[0] == 't':
        continue
    row = [float(n) for n in row]
    # add to portfolios
    for j in range(len(portfolios)):
        means[j] += row[j+1]
        portfolios[j].append(row[j+1])
    # save the data just in case
    rows.append(row)


def _covariance(a, b):
    return np.cov(a,b)

def beta(Rie, Rme):
    return Rie/Rme


print("Total number of rows", len(rows))

print("Question 1")
print ("Mean are ", [entry/len(rows) for entry in means])
print("")
print("Covariance Matrix")
cov = []
for i in range(len(portfolios)):
    s = ""; ll = []
    for j in range(len(portfolios)):
        tmp = _covariance(portfolios[i], portfolios[j])[0][1]
        s += "  " + "%0.4f" % tmp
        ll.append(tmp)
    cov.append(ll)
    print(s)

sigma_m = cov[0][0]
print("")
print("Betas. For A = ", beta(cov[0][1], sigma_m), 
    "For B = ", beta(cov[0][2], sigma_m), "For C = ", beta(cov[0][3], sigma_m))


