library(data.table)
library(scatterD3)
# 
# vse = fread("full1.csv")
# vse = rbind(vse,fread("full2.csv"))
# vse[,mean(util-rand)/mean(best-rand),by=list(method,chooser)]
# 
# vse[chooser=="honBallot",mean(util-rand)/mean(best-rand),by=list(method,chooser)]
# 
# ovse = fread("lowDks2.csv")
# ovse[,mean(util-rand)/mean(best-rand),by=list(method,chooser)]
# 
# ovse[chooser %in% c("honBallot","Oss.hon_strat.","Prob.strat50_hon50."),mean(util-rand)/mean(best-rand),by=list(method,chooser)]
# 
# mvse = fread("media413.csv")
# mvse = rbind(mvse,fread("media41.csv"), fill=T)
# mvse[,mean(util-rand)/mean(best-rand),by=list(method,chooser)]
# 
# mvse[chooser %in% c("honBallot","Oss.hon_strat.","Prob.strat50_hon50."),mean(util-rand)/mean(best-rand),by=list(method,chooser)]
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# fvse = fread("fuzzy5.csv")
# fvse[,mean(util-rand)/mean(best-rand),by=list(method,chooser)]
# 
# fvse = fread("wtf1.csv")
# 
# fvse = rbind(fvse,fread("wtf2.csv"))

fvse = fread("target3.csv")
fuzVses = fvse[,mean(util-rand)/mean(best-rand),by=list(method,chooser)]
etype = fvse[method=="Schulze" & chooser=="honBallot",tallyVal0,by=eid]
names(etype) = c("eid","scenario")
setkey(etype,eid)
setkey(fvse,eid)
fvse=fvse[etype]

interestingStrats = c("honBallot","smartOss","stratBallot","Oss.hon_strat.","Oss.hon_Prob.strat50_hon50..","Prob.strat50_hon50.")
honestScenarios = fvse[chooser %in% interestingStrats,list(vse=mean(util-rand)/mean(best-rand),frequency=.N/dim(etype)[1]),by=list(scenario,chooser,method)]
honestScenarios2 = fvse[chooser %in% interestingStrats,list(vse=mean(util-rand)/mean(best-rand),frequency=.N/dim(etype)[1]),by=list(chooser,method)]
write.csv(honestScenarios,"byScenario.csv")
hmethodlist = honestScenarios2[,method]
methods = unique(hmethodlist)
# methodOrder = methods[c(8,9,14,15,10,#15, #IRNR
#                         11,12, #rp
#                         5,4,3,2,1,6,7,13
#                         #,15 #IRNR at end
#                         )]
allMethodOrder = c("Plurality", "Borda", "Mav", "Mj", "Irv", "Schulze", "Rp", 
                "BulletyApproval60", "IdealApproval", "Score0to2", "Score0to10", 
                "Score0to1000", "Srv0to10", "Srv0to2", "V321")
methodOrder = c("Plurality", "Irv", "BulletyApproval60", "Srv0to10", "V321")
allMethodOrder= unique(c(methodOrder,allMethodOrder))
methodNames = c("Plurality", "IRV", "Approval", "SRV", "3-2-1 voting", 
                allMethodOrder[(length(methodOrder)+1):length(allMethodOrder)])
scenarios = c("cycle", "easy", "spoiler", "squeeze", "chicken", "other")
scenarioFreq = honestScenarios[,list(freq=mean(frequency)),by=scenario]
setkey(scenarioFreq,scenario)
scenarioLabelBase2 = c("2. Easy\n(Cond #1 = Plur #1)", 
                      "5. Chicken dilemma\n(Cond #3 = Plur3 #1)",
                      "6. Other\n",
                      "4. Center squeeze\n(Cond #1 = Plur3 #3)",
                      "3. Spoiler\n(Cond #1 = Plur3 #1)",
                      "1. Condorcet cycle\n"
) 
scenarioLabelBase = c(
                      "1.Cond. cycle",
                      "2.Easy", 
                      "3.Spoiler",
                      "4.Ctr. squeeze",
                      "5.Chicken dilem.",
                      "6.Other"
) 
scenarioLabel = paste0(scenarioLabelBase," (~",round(scenarioFreq[scenarios,freq]*100),"%)")
stratLabel = c("a.100% honest",
               "d.Smart 1-sided strat.",
               "f.100% strategic",
               "e.100% 1-sided strategy","b.50% 1-sided strategy","c.50% strategic")
methodOrder = methods #comment out
honestScenarios[,method:=factor(hmethodlist,levels=allMethodOrder,
                                labels=paste(c(paste0(" ",as.character(1:9)),as.character(10:length(allMethodOrder))),allMethodOrder,sep=". "))]
honestScenarios[,strategy:=factor(chooser, levels=interestingStrats,labels=stratLabel)]
honestScenarios[,`Scenario type`:=factor(scenario,levels=scenarios,labels=scenarioLabel)]
honestScenarios[vse<0,vse:=vse/10]
scatterD3(data = honestScenarios[!is.na(method),], x = vse, y = method, col_var = strategy, symbol_var = `Scenario type`, left_margin = 90, xlim=c(-.2,1.0), size_var=frequency)

numbers = paste0(c(paste0(" ",as.character(1:9)),as.character(10:99)),".")
spaces = c(" ", "\U00a0", "\U2000", "\U2001", "\U2002", "\U2003", "\U2004")
binarycount = expand.grid(1:7,1:7)
invisnumbers = rep(NA,dim(binarycount)[1])
for (i in 1:length(invisnumbers)) {
  invisnumbers[i] = paste0(spaces[as.numeric(binarycount[i,2:1])],collapse="")
}
numbers = invisnumbers

numberedNames = paste(numbers[1:length(methodNames)],methodNames,sep=" ")


honestScenarios2[,method:=factor(hmethodlist,levels=allMethodOrder,labels=numberedNames)]
honestScenarios2[,strategy:=factor(chooser, levels=interestingStrats,labels=stratLabel)]
#honestScenarios2[,`Scenario type`:=factor(scenario,levels=scenarios,labels=scenarioLabel)]
honestScenarios2[vse<0,vse:=vse/10]

#[-grep("IRNR",honestScenarios2[,as.character(method)])]
scatterD3(data = honestScenarios2[as.character(method) %in% levels(honestScenarios2[,method])[1:5],], x = vse, y = method, col_var = strategy, left_margin = 90, xlim=c(.7,1.0))

fvse[,works:=as.integer(tallyVal1)]

#strategic function
stratWorks = fvse[chooser=="Oss.hon_strat.",list(stratWorks=mean(works==1,na.rm=T),
                                    stratBackfire=mean(works==-1,na.rm=T),
                                    frequency=.N/dim(etype)[1]),by=list(method,scenario)]

stratWorks[,`Scenario type`:=factor(scenario,levels=scenarios,labels=scenarioLabel)]
scatterD3(data = stratWorks, x = stratWorks, y = stratBackfire, xlim=c(0,1.0),ylim=c(0,1.0), symbol_var = `Scenario type`, size_var=frequency, col_var=method)



stratWorksAg = fvse[chooser=="Oss.hon_strat.",list(stratWorks=mean(works==1,na.rm=T),
                                                 stratBackfire=mean(works==-1,na.rm=T)),
                    by=list(method)]

scatterD3(data = stratWorksAg, x = stratWorks, y = stratBackfire, xlim=c(0,1.0),ylim=c(0,1.0), col_var=method, lab=method)

#(I think that refining the strategies can improve the function:backfire balance, but it's a)