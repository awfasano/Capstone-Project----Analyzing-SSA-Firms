clear
cd "/Users/anthonyfasano/Desktop/Capstone/Ownership Workspace"
//This looks for all files in the directly titled investor something
local filenames: dir "." files "investor*.csv"
drop _all
//creating a temporary file
tempfile building
quietly save `building', emptyok

//for each of the files in our directory we append the other files with that start with investor onto it
foreach f of local filenames {
import delim using `"`f'"', clear
gen source_file = `"`f'"'
append using `building'
save `"`building'"', replace
}

//finding unique inverstor ids to catch any duplicates
by instrument investorpermid, sort: gen nvals = _n == 1
drop if nvals == 0

save investorInfo, replace

clear
//same idea as above but with ownership
local filenames: dir "." files "owner*.csv"
drop _all
tempfile building
quietly save `building', emptyok
foreach f of local filenames {
import delim using `"`f'"', clear
gen source_file = `"`f'"'
append using `building'
save `"`building'"', replace
}

//turning date strings into a date variable
gen date2 = date(substr(date, 1, 10), "YMD")
format date2 %td


//get the month and year from date because we have to merge investor information with the share information and month and year was a good way to find this because of share offereings and such.
gen month = month(date2)
gen year = year(date2)
drop if missing(investorsharesheld)

save ownershipAll, replace




clear
//same idea as above but with ownership
local filenames: dir "." files "parent*.csv"
drop _all
tempfile building
quietly save `building', emptyok
foreach f of local filenames {
import delim using `"`f'"', clear
gen source_file = `"`f'"'
append using `building'
save `"`building'"', replace
}

//turning date strings into a date variable
gen date2 = date(substr(date, 1, 10), "YMD")
format date2 %td


//get the month and year from date because we have to merge investor information with the share information and month and year was a good way to find this because of share offereings and such.
gen month = month(date2)
gen year = year(date2)
drop if missing(ultimateparentpercentofsharesout)
save parentPercentage.dta,replace



import delimited "sharesheld.csv", clear 
gen date2 = date(substr(date, 1, 10), "YMD")
gen month = month(date2)
gen year = year(date2)
//finding unique values and dropping any duplicates
by instrument year month, sort: gen nvals = _n == 1
drop if nvals == 0
drop nvals

format date2 %td

//dropping observations that do not contain share information
drop if missing(outstandingshares)
save sharesheld, replace

clear 
use ownershipAll
merge m:1 instrument year month using sharesheld.dta

drop _merge
merge m:1 instrument investorpermid using investorInfo
drop if missing(investorpermid)
drop if missing(investorsharesheld)
drop if missing(outstandingshares)
drop if outstandingshares == 1
drop source_file date _merge nvals
//Final file calculating percentage owenership from shares held and outstanding shares of a company
save ownershipAllSSA,replace

clear
use parentPercentage
merge m:1 instrument investorpermid using investorInfo
//drop if missing(investorpermid)
gsort instrument -countryofheadquarters
by instrument: gen countryOfHeadquarterCompany = countryofheadquarters[1]

drop if missing(ultimateparentpercentofsharesout)
drop source_file date _merge nvals
//Final file using Refinitivs percent ownership calculation


replace countryOfHeadquarterCompany = "Nigeria" if instrument == "ARBICO.LG" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "ATIJ.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "BKIJ.J" 
replace countryOfHeadquarterCompany = "Mauritius" if instrument == "CIM.MZ" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "CTOP50J.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "CSPROPJ.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "CVWJ.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "DCCUSDJ.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "DCCUS2J.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "DCPJ.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "DIVTRXJ.J" 
replace countryOfHeadquarterCompany = "Kenya" if instrument == "EGAD.NR" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "EMIJ.J" 
replace countryOfHeadquarterCompany = "Mauritius" if instrument == "ENLG.MZ" 

replace countryOfHeadquarterCompany = "South Africa" if instrument == "ETFPLTJ.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "ETFRHOJ.J" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "ETFSAPJ.J" 

replace countryOfHeadquarterCompany = "South Africa" if instrument == "ETFSAPJ.J" 

replace countryOfHeadquarterCompany = "Nigeria" if instrument == "ETRANZA.LG" 
replace countryOfHeadquarterCompany = "Kenya" if instrument == "EVRD.NR" 
replace countryOfHeadquarterCompany = "Nigeria" if instrument == "FLOURMI.LG" 
replace countryOfHeadquarterCompany = "South Africa" if instrument == "FNBEQFJ.J" 

save parentPercentageAllSSA.dta,replace


clear
//same idea as above but with ownership


import delim using "AllSSA_FirmLevel", clear
gen source_file = "AllSSA_FirmLevel"

gsort instrument -companyname
by instrument: replace exchangename = exchangename[1]
by instrument: replace companyname = companyname[1]
by instrument: replace organizationultimateparent = organizationultimateparent[1]
by instrument: replace countryofheadquarters = countryofheadquarters[1]
by instrument: replace v15 = v15[1]

by instrument: replace naicssectorname = naicssectorname[1]
by instrument: replace naicssectorcode = naicssectorcode[1]
by instrument: replace naicssubsectorname = naicssubsectorname[1]

by instrument: replace naicssubsectorcode = naicssubsectorcode[1]
by instrument: replace ultimateparentid = ultimateparentid[1]

destring financialperiodabsolute, gen(year) ignore("FY")

save "firmNameMetrics", replace
drop if missing(year)

by instrument year, sort: gen nvals = _n == 1 
drop if nvals == 0

merge 1:m instrument year using parentPercentageAllSSA.dta

keep if _merge == 3
drop if missing(investoraddresscountry)

gen chinaInvestor = 1 if investoraddresscountry == "China (Mainland)"
replace chinaInvestor = 0 if investoraddresscountry != "China (Mainland)"

gen chinaTangentInvestor = 1 if investoraddresscountry == "China (Mainland)" | investoraddresscountry == "Hong Kong" | investoraddresscountry == "Singapore" | investoraddresscountry == "Malaysia" | investoraddresscountry == "Taiwan" 
replace chinaTangentInvestor = 0 if missing(chinaTangentInvestor)


gen westernInvestor = 1 if investoraddresscountry == "Australia" | investoraddresscountry == "Austria" | investoraddresscountry == "Belgium" | investoraddresscountry == "Canada" | investoraddresscountry == "Cyprus" | investoraddresscountry == "Denmark" | investoraddresscountry == "France" | investoraddresscountry == "Germany" | investoraddresscountry == "Gibraltar" | investoraddresscountry == "Ireland" | investoraddresscountry == "Italy" | investoraddresscountry == "Israel" | investoraddresscountry == "Liechtenstein" | investoraddresscountry == "Luxembourg" | investoraddresscountry == "Greece" | investoraddresscountry == "Netherlands" | investoraddresscountry == "Norway" | investoraddresscountry == "Sweden" | investoraddresscountry == "Switzerland" | investoraddresscountry == "United Kingdom" | investoraddresscountry == "United States"
replace westernInvestor = 0 if missing(westernInvestor)

gen canadaInvestor = 1 if investoraddresscountry == "Canada"
replace canadaInvestor = 0 if missing(canadaInvestor)

gen AustraliaInvestor = 1 if investoraddresscountry == "Australia"
replace AustraliaInvestor = 0 if missing(AustraliaInvestor)

gen AustriaInvestor = 1 if investoraddresscountry == "Austria"
replace AustriaInvestor = 0 if missing(AustriaInvestor)

gen BelgiumInvestor = 1 if investoraddresscountry == "Belgium"
replace BelgiumInvestor = 0 if missing(BelgiumInvestor)

gen BermudaInvestor = 1 if investoraddresscountry == "Bermuda"
replace BermudaInvestor = 0 if missing(BermudaInvestor)

gen DenmarkInvestor = 1 if investoraddresscountry == "Denmark"
replace DenmarkInvestor = 0 if missing(DenmarkInvestor)

gen FinlandInvestor = 1 if investoraddresscountry == "Finland"
replace FinlandInvestor = 0 if missing(FinlandInvestor)

gen FranceInvestor = 1 if investoraddresscountry == "France"
replace FranceInvestor = 0 if missing(FranceInvestor)

gen GermanyInvestor = 1 if investoraddresscountry == "Germany"
replace GermanyInvestor = 0 if missing(GermanyInvestor)

gen HKInvestor = 1 if investoraddresscountry == "Hong Kong"
replace HKInvestor = 0 if missing(HKInvestor)

gen IndiaInvestor = 1 if investoraddresscountry == "India"
replace IndiaInvestor = 0 if missing(IndiaInvestor)

gen IrelandInvestor = 1 if investoraddresscountry == "Ireland"
replace IrelandInvestor = 0 if missing(IrelandInvestor)

gen ItalyInvestor = 1 if investoraddresscountry == "Italy"
replace ItalyInvestor = 0 if missing(ItalyInvestor)

gen JapanInvestor = 1 if investoraddresscountry == "Japan"
replace JapanInvestor = 0 if missing(JapanInvestor)


gen LuxembourgInvestor = 1 if investoraddresscountry == "Luxembourg"
replace LuxembourgInvestor = 0 if missing(LuxembourgInvestor)


gen NetherlandsInvestor = 1 if investoraddresscountry == "Netherlands"
replace NetherlandsInvestor = 0 if missing(NetherlandsInvestor)


gen NorwayInvestor = 1 if investoraddresscountry == "Norway"
replace NorwayInvestor = 0 if missing(NorwayInvestor)

gen SingaporeInvestor = 1 if investoraddresscountry == "Singapore"
replace SingaporeInvestor = 0 if missing(SingaporeInvestor)

gen SwedenInvestor = 1 if investoraddresscountry == "Sweden"
replace SwedenInvestor = 0 if missing(SwedenInvestor)

gen SwitzerlandInvestor = 1 if investoraddresscountry == "Switzerland"
replace SwitzerlandInvestor = 0 if missing(SwitzerlandInvestor)

gen UAEInvestor = 1 if investoraddresscountry == "United Arab Emirates"
replace UAEInvestor = 0 if missing(UAEInvestor)

gen UKInvestor = 1 if investoraddresscountry == "United Kingdom" | investoraddresscountry == "Guernsey"
replace UKInvestor = 0 if missing(UKInvestor)






//Guernsey part of the UK


gen WestUS = 1 if investoraddresscountry == "Australia" | investoraddresscountry == "Canada" | investoraddresscountry == "France" | investoraddresscountry == "Germany" |  investoraddresscountry == "Italy" | investoraddresscountry == "Israel" | investoraddresscountry == "United Kingdom" | investoraddresscountry == "United States"
replace WestUS = 0 if missing(westernInvestor)


//gen africanInvestor = 1 if westernInvestor == 1 & chinaTangentInvestor == 1
//replace africanInvestor = 0 if missing(africanInvestor)
//drop africanInvestor

gen africanInvestor = 1  if investoraddresscountry == "South Africa" | investoraddresscountry == "Zimbabwe" | investoraddresscountry == "Zambia" | investoraddresscountry == "Botswana" | investoraddresscountry == "Ghana" | investoraddresscountry == "Ivory Coast" | investoraddresscountry == "Lesotho" | investoraddresscountry == "Kenya" | investoraddresscountry == "Mauritania" | investoraddresscountry == "Mauritius" | investoraddresscountry == "Namibia" | investoraddresscountry == "Nigeria" | investoraddresscountry == "Tanzania" | investoraddresscountry == "Togo" | investoraddresscountry == "Tunisia"  | investoraddresscountry == "Uganda"  | investoraddresscountry == "Tunisia"  | investoraddresscountry == "Tunisia"  
replace africanInvestor = 0 if missing(africanInvestor)



gen USinvestor = 1 if investoraddresscountry == "United States"
replace USinvestor = 0 if missing(USinvestor)

egen countryYearDummies = group(countryofheadquarters year)
//Regressions
gen lnRev = ln(revenuefrombusinessactivitiestot)



bysort instrument year: egen canadaInvestment = sum(ultimateparentpercentofsharesout) if canadaInvestor
gsort instrument year -canadaInvestment
by instrument year: replace canadaInvestment = canadaInvestment[1]
replace canadaInvestment = 0 if missing(canadaInvestment)


bysort instrument year: egen AustraliaInvestment = sum(ultimateparentpercentofsharesout) if AustraliaInvestor 
gsort instrument year -AustraliaInvestment
by instrument year: replace AustraliaInvestment = AustraliaInvestment[1]
replace AustraliaInvestment = 0 if missing(AustraliaInvestment)

bysort instrument year: egen BelgiumInvestment = sum(ultimateparentpercentofsharesout) if BelgiumInvestor 
gsort instrument year -BelgiumInvestment
by instrument year: replace BelgiumInvestment = BelgiumInvestment[1]
replace BelgiumInvestment = 0 if missing(BelgiumInvestment)

bysort instrument year: egen BermudaInvestment = sum(ultimateparentpercentofsharesout) if BermudaInvestor 
gsort instrument year -BermudaInvestment
by instrument year: replace BermudaInvestment = BermudaInvestment[1]
replace BermudaInvestment = 0 if missing(BermudaInvestment)


bysort instrument year: egen DenmarkInvestment = sum(ultimateparentpercentofsharesout) if DenmarkInvestor 
gsort instrument year -DenmarkInvestment
by instrument year: replace DenmarkInvestment = DenmarkInvestment[1]
replace DenmarkInvestment = 0 if missing(DenmarkInvestment)



bysort instrument year: egen FranceInvestment = sum(ultimateparentpercentofsharesout) if FranceInvestor  
gsort instrument year -FranceInvestment
by instrument year: replace FranceInvestment = FranceInvestment[1]
replace FranceInvestment = 0 if missing(FranceInvestment)

bysort instrument year: egen GermanyInvestment = sum(ultimateparentpercentofsharesout) if GermanyInvestor  
gsort instrument year -GermanyInvestment
by instrument year: replace GermanyInvestment = GermanyInvestment[1]
replace GermanyInvestment = 0 if missing(GermanyInvestment)

bysort instrument year: egen HKInvestment = sum(ultimateparentpercentofsharesout) if HKInvestor  
gsort instrument year -HKInvestment
by instrument year: replace HKInvestment = HKInvestment[1]
replace HKInvestment = 0 if missing(HKInvestment)

bysort instrument year: egen IndiaInvestment = sum(ultimateparentpercentofsharesout) if IndiaInvestor   
gsort instrument year -IndiaInvestment
by instrument year: replace IndiaInvestment = IndiaInvestment[1]
replace IndiaInvestment = 0 if missing(IndiaInvestment)


bysort instrument year: egen IrelandInvestment = sum(ultimateparentpercentofsharesout) if IrelandInvestor   
gsort instrument year -IrelandInvestment
by instrument year: replace IrelandInvestment = IrelandInvestment[1]
replace IrelandInvestment = 0 if missing(IrelandInvestment)


bysort instrument year: egen ItalyInvestment = sum(ultimateparentpercentofsharesout) if ItalyInvestor  
gsort instrument year -ItalyInvestment
by instrument year: replace ItalyInvestment = ItalyInvestment[1]
replace ItalyInvestment = 0 if missing(ItalyInvestment)

bysort instrument year: egen JapanInvestment = sum(ultimateparentpercentofsharesout) if JapanInvestor  
gsort instrument year -JapanInvestment
by instrument year: replace JapanInvestment = JapanInvestment[1]
replace JapanInvestment = 0 if missing(JapanInvestment)



bysort instrument year: egen LXInvestment = sum(ultimateparentpercentofsharesout) if LuxembourgInvestor   
gsort instrument year -LXInvestment
by instrument year: replace LXInvestment = LXInvestment[1]
replace LXInvestment = 0 if missing(LXInvestment)

bysort instrument year: egen NetherlandsInvestment = sum(ultimateparentpercentofsharesout) if NetherlandsInvestor   
gsort instrument year -NetherlandsInvestment
by instrument year: replace NetherlandsInvestment = NetherlandsInvestment[1]
replace NetherlandsInvestment = 0 if missing(NetherlandsInvestment)

bysort instrument year: egen NorwayInvestment = sum(ultimateparentpercentofsharesout) if NorwayInvestor   
gsort instrument year -NorwayInvestment
by instrument year: replace NorwayInvestment = NorwayInvestment[1]
replace NorwayInvestment = 0 if missing(NorwayInvestment)

bysort instrument year: egen SingnaporeInvestment = sum(ultimateparentpercentofsharesout) if SingaporeInvestor   
gsort instrument year -SingnaporeInvestment
by instrument year: replace SingnaporeInvestment = SingnaporeInvestment[1]
replace SingnaporeInvestment = 0 if missing(SingnaporeInvestment)


bysort instrument year: egen SwedenInvestment = sum(ultimateparentpercentofsharesout) if SwedenInvestor   
gsort instrument year -SwedenInvestment
by instrument year: replace SwedenInvestment = SwedenInvestment[1]
replace SwedenInvestment = 0 if missing(SwedenInvestment)

bysort instrument year: egen SwitzerlandInvestment = sum(ultimateparentpercentofsharesout) if SwitzerlandInvestor   
gsort instrument year -SwitzerlandInvestment
by instrument year: replace SwitzerlandInvestment = SwitzerlandInvestment[1]
replace SwitzerlandInvestment = 0 if missing(SwitzerlandInvestment)

bysort instrument year: egen UAEInvestment = sum(ultimateparentpercentofsharesout) if UAEInvestor   
gsort instrument year -UAEInvestment
by instrument year: replace UAEInvestment = UAEInvestment[1]
replace UAEInvestment = 0 if missing(UAEInvestment)

bysort instrument year: egen UKInvestment = sum(ultimateparentpercentofsharesout) if UKInvestor  
gsort instrument year -UKInvestment
by instrument year: replace UKInvestment = UKInvestment[1]
replace UKInvestment = 0 if missing(UKInvestment)






//
bysort instrument year: egen chineseInvestment = sum(ultimateparentpercentofsharesout) if chinaInvestor
gsort instrument year -chineseInvestment
by instrument year: replace chineseInvestment = chineseInvestment[1]
replace chineseInvestment = 0 if missing(chineseInvestment)

bysort instrument year: egen chinaTangentInvestment = sum(ultimateparentpercentofsharesout) if chinaTangentInvestor
gsort instrument year -chinaTangentInvestment
by instrument year: replace chinaTangentInvestment = chinaTangentInvestment[1]
replace chinaTangentInvestment = 0 if missing(chinaTangentInvestment)

bysort instrument year: egen USInvestment = sum(ultimateparentpercentofsharesout) if USinvestor
gsort instrument year -USInvestment
by instrument year: replace USInvestment = USInvestment[1]
replace USInvestment = 0 if missing(USInvestment)

bysort instrument year: egen africaInvestment = sum(ultimateparentpercentofsharesout) if africanInvestor
gsort instrument year -africaInvestment
by instrument year: replace africaInvestment = africaInvestment[1]
replace africaInvestment = 0 if missing(africaInvestment)

bysort instrument year: egen westernInvestment = sum(ultimateparentpercentofsharesout) if westernInvestor
gsort instrument year -westernInvestment
by instrument year: replace westernInvestment = westernInvestment[1]
replace westernInvestment = 0 if missing(westernInvestment)

collapse (mean) returnonassetsactual pedailytimeseriesratio earningspersharemean companymarketcapitalization priceclose netincomeaftert revenuefrombusinessactivitiestot chinaInvestor chinaTangentInvestor africanInvestor USinvestor countryYearDummies lnRev westernInvestor chineseInvestment chinaTangentInvestment USInvestment africaInvestment westernInvestment canadaInvestment AustraliaInvestment BelgiumInvestment BermudaInvestment DenmarkInvestment FranceInvestment GermanyInvestment HKInvestment IndiaInvestment IrelandInvestment ItalyInvestment JapanInvestment LXInvestment NetherlandsInvestment NorwayInvestment SingnaporeInvestment SwedenInvestment SwitzerlandInvestment UAEInvestment UKInvestment canadaInvestor AustraliaInvestor AustriaInvestor BelgiumInvestor BermudaInvestor DenmarkInvestor FinlandInvestor FranceInvestor GermanyInvestor HKInvestor IndiaInvestor IrelandInvestor ItalyInvestor JapanInvestor LuxembourgInvestor NetherlandsInvestor NorwayInvestor SingaporeInvestor SwedenInvestor SwitzerlandInvestor UAEInvestor UKInvestor , by(year instrument naicssectorname naicssectorcode naicssubsectorname naicssubsectorcode sicindustryname sicindustrygroupname)

gen chinaDummy = 1 if chineseInvestment > 5
replace chinaDummy = 0 if chineseInvestment < 5

gen westernDummy = 1 if westernInvestment > 30 & chineseInvestment < 5
replace westernDummy = 0 if westernInvestment < 30 & chineseInvestment > 5

gen africanDummy = 1 if africaInvestment > 5 & chineseInvestment < 5 & westernInvestment < 35
replace africanDummy = 0 if africaInvestment < 5 & chineseInvestment > 5 & westernInvestment > 5

gen chinaTangentDummy = 1 if chinaTangentInvestment > 3
replace chinaTangentDummy = 0 if chinaTangentInvestment < 3

gen USDummy = 1 if USInvestment > 15 & chineseInvestment < 5
replace USDummy = 0 if USInvestment < 15 & chineseInvestment > 5

gen lnnetincomeaftertax = ln(netincomeaftertax)


replace chineseInvestmentDummy10 = 1 if missing(chineseInvestmentDummy10) 

//chineseInvestment westernInvestment BelgiumInvestment FranceInvestment GermanyInvestment HKInvestment IndiaInvestment JapanInvestment SingnaporeInvestment SwitzerlandInvestment UAEInvestment UKInvestment 

foreach v of varlist westernInvestment {
	capture erase "FinalBalance1.doc"
	foreach num of numlist 3 5 10 12 15{
		gen `v'Dummy`num' = 1 if `v' > `num'
		replace `v'Dummy`num' = 0 if `v' < `num'
	
		foreach x of varlist pedailytimeseriesratio earningspersharemean lnnetincomeaftertax lnRev priceclose companymarketcapitalization {
			reghdfe `x' `v'Dummy`num', absorb(countryYearDummies instrument) cluster(instrument)
					outreg2 chineseInvestmentDummy5 using "FinalBalance1.doc", ctitle(`x') label append
			}
		}
}

reg pedailytimeseriesratio IndiaInvestmentDummy5
outreg2 westernInvestment5 using "FinalBalance1.doc", ctitle(pedailytimeseriesratio) label replace

reg priceclose IndiaInvestmentDummy5
outreg2 westernInvestment3 using "FinalBalance1.doc", ctitle(priceclose) label append

reg lnRev IndiaInvestmentDummy5
outreg2 westernInvestment3 using "FinalBalance1.doc", ctitle(lnRev) label append

reg lnnetincomeaftertax IndiaInvestmentDummy5
outreg2 westernInvestment3 using "FinalBalance1.doc", ctitle(lnnetincomeaftertax) label append

reg companymarketcapitalization IndiaInvestmentDummy5
outreg2 westernInvestment3 using "FinalBalance1.doc", ctitle(companymarketcapitalization) label append

reg earningspersharemean IndiaInvestmentDummy5
outreg2 westernInvestment3 using "FinalBalance1.doc", ctitle(earningspersharemean) label append



drop USInvestmentDummy3





reghdfe lnRev westernInvestment chineseInvestment USInvestment, absorb(countryYearDummies instrument)

gen sqrtWesternInvestment = sqrt(westernInvestment)
gen sqrtchinaTangentInvestment = sqrt(chinaTangentInvestment)
gen sqrtChineseInvestment = sqrt(chineseInvestment)

gen sqrtUSInvestment = sqrt(USInvestment)

reghdfe lnRev sqrtUSInvestment sqrtChineseInvestment sqrtWesternInvestment, absorb(countryYearDummies instrument)
test sqrtUSInvestment sqrtChineseInvestment

reghdfe lnRev sqrtUSInvestment sqrtchinaTangentInvestment sqrtWesternInvestment, absorb(countryYearDummies instrument) cluster(year)
test sqrtUSInvestment sqrtchinaTangentInvestment

reghdfe lnRev USInvestment chineseInvestment africaInvestment africanDummy, absorb(countryYearDummies instrument) cluster(year)

reghdfe lnRev chinaDummy, absorb(countryYearDummies instrument) cluster(instrument)
outreg2 treat_cluster using "REVChinaUSCollapsed.doc", ctitle("Year country firm FE") label append

xtreg lnRev chinaDummy i.(countryYearDummies)



reghdfe lnRev USInvestmentDummy3 chineseInvestmentDummy SingnaporeInvestment5, absorb(countryYearDummies instrument) cluster(instrument)
test chineseInvestmentDummy5 BelgiumInvestmentDummy5 
test chineseInvestmentDummy5 IndiaInvestmentDummy5
test chineseInvestmentDummy5 HKInvestmentDummy5




reghdfe lnnetincomeaftertax BelgiumInvestmentDummy5 chineseInvestmentDummy5 IndiaInvestmentDummy5 HKInvestmentDummy5, absorb(countryYearDummies instrument) cluster(instrument)
test chineseInvestmentDummy5 BelgiumInvestmentDummy5 
test chineseInvestmentDummy5 IndiaInvestmentDummy5
test chineseInvestmentDummy5 HKInvestmentDummy5



reghdfe pedailytimeseriesratio BelgiumInvestmentDummy5 chineseInvestmentDummy5 IndiaInvestmentDummy5 HKInvestmentDummy5, absorb(countryYearDummies instrument) cluster(instrument)

test chineseInvestmentDummy5 BelgiumInvestmentDummy5 
test chineseInvestmentDummy5 IndiaInvestmentDummy5
test chineseInvestmentDummy5 HKInvestmentDummy5



reghdfe companymarketcapitalization BelgiumInvestmentDummy5 chineseInvestmentDummy5 IndiaInvestmentDummy5 HKInvestmentDummy5, absorb(countryYearDummies instrument) cluster(instrument)

test chineseInvestmentDummy5 BelgiumInvestmentDummy5 
test chineseInvestmentDummy5 IndiaInvestmentDummy5
test chineseInvestmentDummy5 HKInvestmentDummy5


reghdfe earningspersharemean BelgiumInvestmentDummy5 chineseInvestmentDummy5 IndiaInvestmentDummy5 HKInvestmentDummy5, absorb(countryYearDummies instrument) cluster(instrument)
outreg2 westernInvestment3 using "Results.doc", ctitle("EPS (USD)") label append

test chineseInvestmentDummy5 BelgiumInvestmentDummy5 
test chineseInvestmentDummy5 IndiaInvestmentDummy5
test chineseInvestmentDummy5 HKInvestmentDummy5


reghdfe priceclose BelgiumInvestmentDummy5 chineseInvestmentDummy5 IndiaInvestmentDummy5 HKInvestmentDummy5, absorb(countryYearDummies instrument) cluster(instrument)
outreg2 westernInvestment3 using "Results.doc", ctitle("Stock Price") label append

test chineseInvestmentDummy5 BelgiumInvestmentDummy5 
test chineseInvestmentDummy5 IndiaInvestmentDummy5
test chineseInvestmentDummy5 HKInvestmentDummy5



estpost tabstat lnRev lnnetincomeaftertax pedailytimeseriesratio companymarketcapitalization earningspersharemean priceclose stat(mean sd min max) if chineseInvestmentDummy5
estpost tabstat lnRev lnnetincomeaftertax pedailytimeseriesratio companymarketcapitalization earningspersharemean priceclose stat(mean sd min max) if chineseInvestmentDummy12
estpost tabstat lnRev lnnetincomeaftertax pedailytimeseriesratio companymarketcapitalization earningspersharemean priceclose stat(mean sd min max) if USInvestmentDummy5
estpost tabstat lnRev lnnetincomeaftertax pedailytimeseriesratio companymarketcapitalization earningspersharemean priceclose stat(mean sd min max) if USInvestmentDummy12
estpost tabstat lnRev lnnetincomeaftertax pedailytimeseriesratio companymarketcapitalization earningspersharemean priceclose stat(mean sd min max) if SingnaporeInvestmentDummy5
estpost tabstat lnRev lnnetincomeaftertax pedailytimeseriesratio companymarketcapitalization earningspersharemean priceclose stat(mean sd min max) if SingnaporeInvestmentDummy12
esttab . using someFile.rtf

reghdfe lnRev USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)
outreg2 westernInvestment3 using "Results1.doc", ctitle("Ln Revenue (USD)") label replace

reghdfe lnnetincomeaftertax USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)
outreg2 westernInvestment3 using "Results1.doc", ctitle("Ln Net Income (USD)") label append

reghdfe pedailytimeseriesratio USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument) 
outreg2 westernInvestment3 using "Results1.doc", ctitle("PE Ratio") label append

reghdfe companymarketcapitalization USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)
outreg2 westernInvestment3 using "Results1.doc", ctitle("Market Cap (USD)") label append

reghdfe earningspersharemean USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)
outreg2 westernInvestment3 using "Results1.doc", ctitle("EPS (USD)") label append

reghdfe priceclose USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument) 
outreg2 westernInvestment3 using "Results1.doc", ctitle("Stock Price") label append


reghdfe lnRev USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument) cluster(instrument)
test chineseInvestmentDummy5 SingnaporeInvestmentDummy5
test chineseInvestmentDummy5 USInvestmentDummy5
outreg2 westernInvestment3 using "Results1a.doc", ctitle("Ln Revenue (USD)") label replace

reghdfe lnnetincomeaftertax USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy5 SingnaporeInvestmentDummy5
test chineseInvestmentDummy5 USInvestmentDummy5

outreg2 westernInvestment3 using "Results1a.doc", ctitle("Ln Net Income (USD)") label append

reghdfe pedailytimeseriesratio USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy5 SingnaporeInvestmentDummy5
test chineseInvestmentDummy5 USInvestmentDummy5

outreg2 westernInvestment3 using "Results1a.doc", ctitle("PE Ratio") label append

reghdfe companymarketcapitalization USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy5 SingnaporeInvestmentDummy5
test chineseInvestmentDummy5 USInvestmentDummy5

outreg2 westernInvestment3 using "Results1a.doc", ctitle("Market Cap (USD)") label append

reghdfe earningspersharemean USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy5 SingnaporeInvestmentDummy5
test chineseInvestmentDummy5 USInvestmentDummy5


outreg2 westernInvestment3 using "Results1a.doc", ctitle("EPS (USD)") label append

reghdfe priceclose USInvestmentDummy5 chineseInvestmentDummy5 SingnaporeInvestmentDummy5, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy5 SingnaporeInvestmentDummy5
test chineseInvestmentDummy5 USInvestmentDummy5




reghdfe lnRev USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)
outreg2 westernInvestment3 using "Results1b.doc", ctitle("Ln Revenue (USD)") label replace

reghdfe lnnetincomeaftertax USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)
outreg2 westernInvestment3 using "Results1b.doc", ctitle("Ln Net Income (USD)") label append

reghdfe lnnetincomeaftertax USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)
corr res L.res


reghdfe lnnetincomeaftertax chineseInvestmentDummy12 (i.year)##chineseInvestmentDummy12, absorb(instrument country)


reg lnnetincomeaftertax chineseInvestmentDummy5 i.year##chineseInvestmentDummy5 i.year
outreg2 westernInvestment3 using "parallel2.doc", ctitle("Net Income") label append



xtregar  lnnetincomeaftertax USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12 i.year, fe i(instrumentGroup) 

reghdfe pedailytimeseriesratio USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument) 
outreg2 westernInvestment3 using "Results1b.doc", ctitle("PE Ratio") label append

reghdfe companymarketcapitalization USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)
outreg2 westernInvestment3 using "Results1b.doc", ctitle("Market Cap (USD)") label append

reghdfe earningspersharemean USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)
outreg2 westernInvestment3 using "Results1b.doc", ctitle("EPS (USD)") label append

reghdfe priceclose USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument) 
outreg2 westernInvestment3 using "Results1b.doc", ctitle("Stock Price") label append


reghdfe lnRev USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument) cluster(instrument)
test chineseInvestmentDummy12 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy12 USInvestmentDummy12


reghdfe lnnetincomeaftertax USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy12 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy12 USInvestmentDummy12

reghdfe pedailytimeseriesratio USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy12 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy12 USInvestmentDummy12



reghdfe companymarketcapitalization USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy12 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy12 USInvestmentDummy12


reghdfe earningspersharemean USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)  cluster(instrument)

test chineseInvestmentDummy12 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy12 USInvestmentDummy12

reghdfe priceclose USInvestmentDummy12 chineseInvestmentDummy12 SingnaporeInvestmentDummy12, absorb(countryYearDummies instrument)  cluster(instrument)
test chineseInvestmentDummy12 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy12 USInvestmentDummy12







reghdfe lnRev BelgiumInvestmentDummy10 chineseInvestmentDummy10 IndiaInvestmentDummy10 HKInvestmentDummy10, absorb(countryYearDummies instrument) cluster(instrument)


test chineseInvestmentDummy10 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy10 USInvestmentDummy12
eststo ChinaHK
esttab using "ftests.doc", replace


outreg2 westernInvestment3 using "Results3.doc", ctitle("Ln Revenue (USD)") label replace




reghdfe lnnetincomeaftertax BelgiumInvestmentDummy10 chineseInvestmentDummy10 IndiaInvestmentDummy10 HKInvestmentDummy10, absorb(countryYearDummies instrument) cluster(instrument)
outreg2 westernInvestment3 using "Results3.doc", ctitle("Ln Net Income (USD)") label append

test chineseInvestmentDummy10 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy10 USInvestmentDummy12

reghdfe pedailytimeseriesratio BelgiumInvestmentDummy10 chineseInvestmentDummy10 IndiaInvestmentDummy10 HKInvestmentDummy10, absorb(countryYearDummies instrument) cluster(instrument)
outreg2 westernInvestment3 using "Results3.doc", ctitle("PE Ratio") label append

test chineseInvestmentDummy10 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy10 USInvestmentDummy12



reghdfe companymarketcapitalization BelgiumInvestmentDummy10 chineseInvestmentDummy10 IndiaInvestmentDummy10 HKInvestmentDummy10, absorb(countryYearDummies instrument) cluster(instrument)
outreg2 westernInvestment3 using "Results3.doc", ctitle("Market Cap (USD)") label append

test chineseInvestmentDummy10 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy10 USInvestmentDummy12


reghdfe earningspersharemean BelgiumInvestmentDummy10 chineseInvestmentDummy10 IndiaInvestmentDummy10 HKInvestmentDummy10, absorb(countryYearDummies instrument) cluster(instrument)
outreg2 westernInvestment3 using "Results3.doc", ctitle("EPS (USD)") label append

test chineseInvestmentDummy10 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy10 USInvestmentDummy12

reghdfe priceclose BelgiumInvestmentDummy10 chineseInvestmentDummy10 IndiaInvestmentDummy10 HKInvestmentDummy10, absorb(countryYearDummies instrument) cluster(instrument)
outreg2 westernInvestment3 using "Results3.doc", ctitle("Stock Price") label append

test chineseInvestmentDummy10 SingnaporeInvestmentDummy12 
test chineseInvestmentDummy10 USInvestmentDummy12







test USDummy chinaDummy
outreg2 treat_cluster using "REVChinaUSCollapsed.doc", ctitle("Year country firm FE") label append

reg pedailytimeseriesratio chineseInvestmentDummy5 if tau == 0
outreg2 chineseInvestmentDummy5 using "FinalBalance.tex", ctitle("Poverty Rate") label replace
reg earningspersharemean chineseInvestmentDummy5 if year == china_year1 //group(groupID) 
outreg2 chineseInvestmentDummy5 using "FinalBalance.tex", ctitle("Population") label append
reg lnnetincomeaftertax chineseInvestmentDummy5  if year == china_year1 //, group(groupID) 
outreg2 chineseInvestmentDummy5 using "FinalBalance.doc", ctitle("% White") label append
reg priceclose chineseInvestmentDummy5 if year == china_year1
outreg2 chineseInvestmentDummy5 using "FinalBalance.tex", ctitle("% with High School Diploma") label append

global pedailytimeseriesratio earningspersharemean lnnetincomeaftertax lnRev priceclose companymarketcapitalization
global outcomes "pedailytimeseriesratio earningspersharemean lnnetincomeaftertax lnRev priceclose companymarketcapitalization"



drop china_int china_year1 china_year tau minus* plus* zero
sort instrument year
gen china_int = (chineseInvestmentDummy12 ==1 & chineseInvestmentDummy12[_n-1]==0) & (instrument == instrument[_n-1])
gen china_year1 = year if china_int==1
egen china_year = min(china_year1), by(instrument)
gen tau = year-china_year  //Define leads and lags
qui tab tau if tau<0, generate(minus)  //Generate lead dummies
qui tab tau if tau>0, generate(plus)  //Generate lag dummies
gen zero = 0   //All differences will be relative to the *difference* observed in time 0. Note that by design, time 0 varies from branch to branch. 
foreach var of varlist minus* plus* {
	replace `var' = 0 if `var' ==.  //Replace the missing values in the leads and lags dummies for zeros. Note that missing values were there because of the "if" in lines 164 and 165
}

global minus "minus6 minus7 minus8 minus9 minus10 minus11 minus12" 
//global minus "minus14 minus15 minus16 minus17 minus18 minus19 minus20 minus21 minus22"  //We estimate the model with ALL dummies, but graph 10 leads. How do we know which dummies to include? A: check the variables' labels to see which ones correspond to -10 to -1.

 //We estimate the model with ALL dummies, but graph 10 leads. How do we know which dummies to include? A: check the variables' labels to see which ones correspond to -10 to -1.
global plus "plus1 plus2 plus3 plus4 plus5 plus6" //We estimate the model with ALL dummies, but graph 10 lags

//xtreg lnRev minus* zero plus* i.instrumentGroup, fe i(countryYearDummies) //cluster(instrumentGroup)  //Estimate the event study note that we estimate it with ALL dummies. In general, the 
reghdfe lnnetincomeaftertax minus* zero plus*, absorb(countryYearDummies instrument) cluster(instrument)

//concensus is to *plot* the leads and lags with balanced sample. 
//coefplot, order($minus zero $plus) keep($minus zero $plus) vertical yline(0) xline(10.5, lpattern(dash)) omitted levels(95) legend(order(1 "95% CI" 2 "Point estimate")) ciopts(recast(rcap)) xlabel(1 "-9" 2 "-8" 3 "-7" 4 "-6" 5 "-5" 6 "-4" 7 "3" 8 "2" 9 "1" 10 "0" 11 "1" 12 "2" 13 "3" 14 "5" 15 "6" 16 "7" 17 "8" 18 "9", valuelabel) xtitle("Year") ytitle("Estimates") title("Singapore  5% Threshold-Event Study")

coefplot, order($minus zero $plus) keep($minus zero $plus) vertical yline(0) xline(7.5, lpattern(dash)) omitted levels(95) legend(order(1 "95% CI" 2 "Point estimate")) ciopts(recast(rcap)) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6", valuelabel) xtitle("Year") ytitle("Estimates") title("Chinese Investment at 5% Threshold Revenue")



csdid  lnRev , ivar(instrumentGroup) time(year) gvar(china_year) method(dripw) agg(event) long2 
csdid_plot 


drop USInvestmentDummy12_int
drop USInvestmentDummy12_yr1
drop USInvestmentDummy12_yr

drop SingnaporeInvestmentDummy12_int
drop SingnaporeInvestmentDummy12_yr1
drop SingnaporeInvestmentDummy12_yr


foreach var of varlist SingnaporeInvestmentDummy12{
	//gen `var'_int = (`var' ==1 & `var'[_n-1]==0) & (instrument == instrument[_n-1])
	//gen `var'_yr1 = year if `var'_int==1
	//egen long `var'_yr = min(`var'_yr1), by(instrument)
	foreach x in $outcomes{
		reg `var'_yr `x' if year == `var'_yr
		outreg2 chineseInvestmentDummy5 using "entry19.doc", ctitle(`var') label
	}
}
count if USInvestmentDummy5_yr == year


drop china_int10 china_year110 china_year10 
sort instrument year
gen china_int10 = (chineseInvestmentDummy12 ==1 & chineseInvestmentDummy12[_n-1]==0) & (instrument == instrument[_n-1])
gen china_year110 = year if china_int10==1
egen china_year10 = mean(china_year110), by(instrument)

replace china_year10 = 2014 if instrument == "KCB.NR" 
replace china_year10 = 2018 if instrument == "KCB.NR" 



reg lnRev chineseInvestmentDummy5 if year < china_year

reg lnRev chineseInvestmentDummy12 if year < china_year110


drop india_int india_year1 india_year tau minus* plus* zero
sort instrument year
gen india_int = (chineseInvestmentDummy5==1 & chineseInvestmentDummy5[_n-1]==0) & (instrument == instrument[_n-1])
gen india_year1 = year if india_int==1
egen india_year = mean(india_year1), by(instrument)
gen tau = year-india_year  //Define leads and lags
qui tab tau if tau<0, generate(minus)  //Generate lead dummies
qui tab tau if tau>0, generate(plus)  //Generate lag dummies
gen zero = 0   //All differences will be relative to the *difference* observed in time 0. Note that by design, time 0 varies from branch to branch. 
foreach var of varlist minus* plus* {
	replace `var' = 0 if `var' ==.  //Replace the missing values in the leads and lags dummies for zeros. Note that missing values were there because of the "if" in lines 164 and 165
}

global minus "minus1 minus2 minus3 minus4 minus5 minus6"  //We estimate the model with ALL dummies, but graph 10 leads. How do we know which dummies to include? A: check the variables' labels to see which ones correspond to -10 to -1.
global plus "plus1 plus2 plus3 plus4 plus5 plus6" //We estimate the model with ALL dummies, but graph 10 lags


//xtreg lnRev minus* zero plus* i.instrumentGroup, fe i(countryYearDummies) //cluster(instrumentGroup)  //Estimate the event study note that we estimate it with ALL dummies. In general, the 
reghdfe lnRev minus* zero plus*, absorb(countryYearDummies instrument) cluster(instrument)

//concensus is to *plot* the leads and lags with balanced sample. 
coefplot, order($minus zero $plus) keep($minus zero $plus) vertical yline(0) xline(7.5, lpattern(dash)) omitted levels(95) legend(order(1 "95% CI" 2 "Point estimate")) ciopts(recast(rcap)) xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "5" 13 "6", valuelabel) xtitle("Year") ytitle("Estimates") title("12% Threshold of Singapore Investors Event Study")
		
	
	
egen instrumentGroup = group(instrument)
	
tsset instrumentGroup year
preserve
collapse (mean) chineseInvestmentDummy3 , by(year) 
tsline chineseInvestmentDummy3 if year < 2022, ytitle("Fraction of States with Chinese Investors") title("Staggered Entry of SSA Firms with Chinese Investors")
restore

	
	
replace china_year = 0 if missing(china_year)

csdid  lnRev , ivar(instrumentGroup) time(year) gvar(china_year) method(dripw) agg(event) long2 
csdid_plot 


tw scatter lnRev year if USDummy == 1 
tw scatter lnRev year if chinaDummy == 1 
tw scatter lnRev year if chinaTangentDummy == 1 
tw scatter lnRev year if africanDummy == 1 
tw scatter lnRev year if westernDummy == 1 

save almostcompletedDataset.dta, replace


