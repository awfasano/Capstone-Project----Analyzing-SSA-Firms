import eikon as ek #v0.14
import pandas as pd #v19
import matplotlib as plt

ek.set_app_key('02851dc6e4d9480aad456d22426172260dd29da0')
countryCodes = 'AO,CM,CF,TD,CG,CD,GQ,GA,ST,BJ,BF,CV,GM,GH,GN,GW,CI,LR,ML,MR,NE,NG,SH,SN,SL,TG,BW,LS,NA,ZA,SZ,BI,KM,DJ,ER,ET,KE,G,MW,MU,YT,MZ,RE,RW,SC,SO,TZ,UG,ZM,ZW'
screener_exp ='SCREEN(U(IN(Equity(active or inactive,public,primary))), IN(TR.ExchangeCountryCode,%s), CURN=USD)'%(countryCodes)
##fieldsrevenue = ['TR.CompanyName', 'TR.ROAActValue','TR.F.TotRevenue(Curn=USD).date', 'TR.F.TotRevenue(Curn=USD)','TR.F.TotRevenue(Curn=USD).fxRate', 'TR.F.TotRevenue(Curn=USD).fperiod','TR.F.TotRevenue(Curn=USD).periodenddate','TR.F.TotRevenue(Curn=USD).currency', 'TR.F.TotRevenue(Curn=USD).companyCurrency','TR.UltimateParent']

##you need this
fields = ['TR.SharesHeld','TR.SharesHeld.investorpermid','TR.SharesHeld.date']
d = {}
for i in range(25):
    j = i + 1
    if i == 0:
        start = f'-{j:.0f}CY'
        end = f'{i:.0f}CY'
        call = {'Period':'FY0', 'SDate': start, 'EDate':end,'Frq': 'Y'}

        d["sharesHeld" + str(i)], e = ek.get_data(screener_exp, fields, call)
    else:
        start = f'-{j:.0f}CY'
        end = f'-{i:.0f}CY'
        call = {'Period':'FY0', 'SDate': start, 'EDate':end,'Frq': 'Y'}
        d["sharesHeld" + str(i)], e = ek.get_data(screener_exp, fields, call)

##df1, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-1CY', 'EDate':'0CY','Frq': 'Y'})
##df1, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-1CY', 'EDate':'-1CY','Frq': 'Y'})
##df2, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-2CY', 'EDate':'-1CY','Frq': 'Y'})
##df3, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-3CY', 'EDate':'-2CY','Frq': 'Y'})
##df4, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-8CY', 'EDate':'-6CY','Frq': 'Y'})
##df5, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-10CY', 'EDate':'-8CY','Frq': 'Y'})
##df6, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-12CY', 'EDate':'-10CY','Frq': 'Y'})
##df7, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-14CY', 'EDate':'-12CY','Frq': 'Y'})
##df8, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-16CY', 'EDate':'-14CY','Frq': 'Y'})
##df9, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-18CY', 'EDate':'-16CY','Frq': 'Y'})
##df10, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-20CY', 'EDate':'-18CY','Frq': 'Y'})
##df11, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-20CY', 'EDate':'-18CY','Frq': 'Y'})
##df12, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-22CY', 'EDate':'-20CY','Frq': 'Y'})
##df13, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-24CY', 'EDate':'-22CY','Frq': 'Y'})
##df14, e = ek.get_data(screener_exp, fields, {'Period':'FY0', 'SDate': '-25CY', 'EDate':'-24CY','Frq': 'Y'})




fields1 = ['TR.SharesOutstanding.date','TR.SharesOutstanding']
dfShares, e = ek.get_data(screener_exp, fields1, {'Period':'FY0', 'SDate': '-25CY', 'EDate':'0CY','Frq': 'M'})



fields2 = ['TR.InvestorFullName.investorpermid','TR.InvestorFullName.investorid','TR.InvestorFullName', 'TR.InvAddrCountry','TR.InvestorTypeId', 'TR.FundInvtStyleCode']
for i in range(25):
    j = i + 1
    if i == 0:
        start = f'-{j:.0f}CY'
        end = f'{i:.0f}CY'
        call = {'Period':'FY0', 'SDate': start, 'EDate':end,'Frq': 'Y'}
        d["investors" + str(i)], e = ek.get_data(screener_exp, fields2, call)
        
    else:
        
        start = f'-{j:.0f}CY'
        end = f'-{i:.0f}CY'
        call = {'Period':'FY0', 'SDate': start, 'EDate':end,'Frq': 'Y'}
        d["investors" + str(i)], e = ek.get_data(screener_exp, fields2, call)

##dfInvestor1, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-2CY', 'EDate':'0CY','Frq': 'Y'})
##dfInvestor2, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-4CY', 'EDate':'-2CY','Frq': 'Y'})
##dfInvestor3, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-6CY', 'EDate':'-4CY','Frq': 'Y'})
##dfInvestor4, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-8CY', 'EDate':'-6CY','Frq': 'Y'})
##dfInvestor5, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-10CY', 'EDate':'-8CY','Frq': 'Y'})
##dfInvestor6, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-12CY', 'EDate':'-10CY','Frq': 'Y'})
##dfInvestor7, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-14CY', 'EDate':'-12CY','Frq': 'Y'})
##dfInvestor8, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-16CY', 'EDate':'-14CY','Frq': 'Y'})
##dfInvestor9, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-18CY', 'EDate':'-16CY','Frq': 'Y'})
##dfInvestor10, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-20CY', 'EDate':'-18CY','Frq': 'Y'})
##dfInvestor11, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-22CY', 'EDate':'-20CY','Frq': 'Y'})
##dfInvestor12, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-24CY', 'EDate':'-22CY','Frq': 'Y'})
##dfInvestor13, e = ek.get_data(screener_exp, fields2, {'Period':'FY0', 'SDate': '-25CY', 'EDate':'-24CY','Frq': 'Y'})


fields3 = ['TR.UltPrntPctOfShrsOutHld','TR.UltPrntPctOfShrsOutHld.date','TR.UltPrntPctOfShrsOutHld.investorid','TR.InvestorTypeId','TR.UltPrntPctOfShrsOutHld.investorpermid', 'TR.UltimateParentCountryHQ', 'TR.FundInvtStyleCode']
##TR.OwnUltParentId
for i in range(25):
    j = i + 1
    if i == 0:
        start = f'-{j:.0f}CY'
        end = f'{i:.0f}CY'
        call = {'Period':'FY0', 'SDate': start, 'EDate':end,'Frq': 'Y'}

        d["parent" + str(i)], e = ek.get_data(screener_exp, fields3, call)
    else:
        start = f'-{j:.0f}CY'
        end = f'-{i:.0f}CY'
        call = {'Period':'FY0', 'SDate': start, 'EDate':end,'Frq': 'Y'}
        d["parent" + str(i)], e = ek.get_data(screener_exp, fields3, call)




##dfParent1, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-2CY', 'EDate':'0CY','Frq': 'Y'})
##dfParent2, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-4CY', 'EDate':'-2CY','Frq': 'Y'})
##dfParent3, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-6CY', 'EDate':'-4CY','Frq': 'Y'})
##dfParent4, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-8CY', 'EDate':'-6CY','Frq': 'Y'})
##dfParent5, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-10CY', 'EDate':'-8CY','Frq': 'Y'})
##dfParent6, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-12CY', 'EDate':'-10CY','Frq': 'Y'})
##dfParent7, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-14CY', 'EDate':'-12CY','Frq': 'Y'})
##dfParent8, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-16CY', 'EDate':'-14CY','Frq': 'Y'})
##dfParent9, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-18CY', 'EDate':'-16CY','Frq': 'Y'})
##dfParent10, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-20CY', 'EDate':'-18CY','Frq': 'Y'})
##dfParent11, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-22CY', 'EDate':'-20CY','Frq': 'Y'})
##dfParent12, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-24CY', 'EDate':'-22CY','Frq': 'Y'})
##dfParent13, e = ek.get_data(screener_exp, fields3, {'Period':'FY0', 'SDate': '-25CY', 'EDate':'-24CY','Frq': 'Y'})


dfShares.to_csv('sharesheld.csv')
for i in range(25):
    parent = f"parent{i}.csv"
    investor = f"investor{i}.csv"
    ownership = f"ownership{i}.csv"
    d["parent" + str(i)].to_csv(parent)
    d["investors" + str(i)].to_csv(investor)
    d["sharesHeld" + str(i)].to_csv(ownership)



##dfParent1.to_csv('parent1.csv')
##dfParent2.to_csv('parent2.csv')
##dfParent3.to_csv('parent3.csv')
##dfParent4.to_csv('parent4.csv')
##dfParent5.to_csv('parent5.csv')
##dfParent6.to_csv('parent6.csv')
##dfParent7.to_csv('parent7.csv')
##dfParent8.to_csv('parent8.csv')
##dfParent9.to_csv('parent9.csv')
##dfParent10.to_csv('parent10.csv')
##dfParent11.to_csv('parent11.csv')
##dfParent12.to_csv('parent12.csv')
##dfParent13.to_csv('parent13.csv')
##
##
##df1.to_csv('ownership1.csv')
##df2.to_csv('ownership2.csv')
##df3.to_csv('ownership3.csv')
##df4.to_csv('ownership4.csv')
##df5.to_csv('ownership5.csv')
##df6.to_csv('ownership6.csv')
##df7.to_csv('ownership7.csv')
##df8.to_csv('ownership8.csv')
##df9.to_csv('ownership9.csv')
##
##dfInvestor1.to_csv('investor1.csv')
##dfInvestor2.to_csv('investor2.csv')
##dfInvestor3.to_csv('investor3.csv')
##dfInvestor4.to_csv('investor4.csv')
##dfInvestor5.to_csv('investor5.csv')
##dfInvestor6.to_csv('investor6.csv')
##dfInvestor7.to_csv('investor7.csv')
##dfInvestor8.to_csv('investor8.csv')
##dfInvestor9.to_csv('investor9.csv')
##dfInvestor10.to_csv('investor10.csv')
##dfInvestor11.to_csv('investor11.csv')
##dfInvestor12.to_csv('investor12.csv')
##dfInvestor13.to_csv('investor13.csv')




