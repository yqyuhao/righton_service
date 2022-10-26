library(dplyr)
library(tidyr)
args<-commandArgs(T)
nowpath=args[1]
config_name=args[2]
#获取config文件sample与panel信息
config=read.csv(config_name,header = F)
if(ncol(config)==3){config=unite(config, "V2",V1 , V2, sep = "_", remove = T)}
colnames(config)=c('sample','panel')
panel=distinct(config, panel, .keep_all = F) 
round_dir=paste0(nowpath,'/filter01/round')
unique_panel=paste0(round_dir,'/unique_panel')
if(!dir.exists(unique_panel)){dir.create(unique_panel)}
#同个panel下spot去重表再合并
for(panel_n in panel$panel){
  pos_panel=which(config$panel==as.character(panel_n))
  print(paste0(panel_n,':',sum(config$panel==as.character(panel_n))))
  if(length(pos_panel)!=1){
    data.merge=read.table(paste0(round_dir,'/',as.character(config$sample[pos_panel[1]]),'.round.xls'),sep = '\t',header = T,quote = '',colClasses = c("character"))
    data.merge=data.merge[,1:69]
    
    if(nrow(data.merge)!=0){
      data.merge$panel=as.character(panel_n)
      adapter=as.character(config$sample[which(config$panel==as.character(panel_n))])[1]
      for (k in 2:length(pos_panel)){
        adapter=paste0(adapter,';',as.character(config$sample[which(config$panel==as.character(panel_n))])[k])
      }
      data.merge$adapter=as.character(adapter)
      data.merge=data.merge[,c(1:5,70,71)]
      data.merge$Chr=as.character(data.merge$Chr)
      data.merge$Start=as.character(data.merge$Start)
      data.merge$End=as.character(data.merge$End)
      data.merge$Ref=as.character(data.merge$Ref)
      data.merge$Alt=as.character(data.merge$Alt)
      data.merge$panel=as.character(data.merge$panel)
      data.merge$adapter=as.character(data.merge$adapter)
      
    }else{
      data.merge=data.merge[,1:7]
      colnames(data.merge)=c('Chr','Start','End','Ref','Alt','panel','adapter')
    }
    for (i in 2:length(pos_panel)) {
      data.new=read.table(paste0(round_dir,'/',as.character(config$sample[pos_panel[i]]),'.round.xls'),sep = '\t',header = T,quote = '',colClasses = c("character"))
      data.new=data.new[,1:69]
      if(nrow(data.new)!=0){
        data.new$panel=as.character(panel_n)
        adapter=as.character(config$sample[which(config$panel==as.character(panel_n))])[1]
        for (n in 2:length(pos_panel)){
          adapter=paste0(adapter,';',as.character(config$sample[which(config$panel==as.character(panel_n))])[n])
        }
        data.new$adapter=as.character(adapter)
        data.new=data.new[,c(1:5,70,71)]
        data.new$Chr=as.character(data.new$Chr)
        data.new$Start=as.character(data.new$Start)
        data.new$End=as.character(data.new$End)
        data.new$Ref=as.character(data.new$Ref)
        data.new$Alt=as.character(data.new$Alt)
        data.new$panel=as.character(data.new$panel)
        data.new$adapter=as.character(data.new$adapter)
        
      }else{
        data.new=data.new[,1:7]
        colnames(data.new)=c('Chr','Start','End','Ref','Alt','panel','adapter')
      }
      data.merge=rbind(data.merge,data.new)
    }
    data.merge=unique(data.merge)
    write.csv(data.merge,file = paste0(unique_panel,'/',panel_n,'.csv'),row.names=FALSE)
  }else{
    data.merge=read.table(paste0(round_dir,'/',as.character(config$sample[pos_panel[1]]),'.round.xls'),sep = '\t',header = T,quote = '',colClasses = c("character"))
    data.merge=data.merge[,1:69]
    if(nrow(data.merge)!=0){
      data.merge$panel=as.character(panel_n)
      data.merge$adapter=as.character(config$sample[which(config$panel==as.character(panel_n))])[1]
      data.merge=data.merge[,c(1:5,70,71)]
      data.merge$Chr=as.character(data.merge$Chr)
      data.merge$Start=as.character(data.merge$Start)
      data.merge$End=as.character(data.merge$End)
      data.merge$Ref=as.character(data.merge$Ref)
      data.merge$Alt=as.character(data.merge$Alt)
      data.merge$panel=as.character(data.merge$panel)
      data.merge$adapter=as.character(data.merge$adapter)
    }else{
      data.merge=data.merge[,1:7]
      colnames(data.merge)=c('Chr','Start','End','Ref','Alt','panel','adapter')
    }
    write.csv(data.merge,file = paste0(unique_panel,'/',panel_n,'.csv'),row.names=FALSE)
  }
}
dir_panel=list.files(unique_panel)
dir_panel_n=length(dir_panel)
merge.panel = read.csv(paste0(unique_panel,'/',dir_panel[1]))
merge.panel$Chr=as.character(merge.panel$Chr)
merge.panel$Start=as.character(merge.panel$Start)
merge.panel$End=as.character(merge.panel$End)
merge.panel$Ref=as.character(merge.panel$Ref)
merge.panel$Alt=as.character(merge.panel$Alt)
merge.panel$panel=as.character(merge.panel$panel)
merge.panel$adapter=as.character(merge.panel$adapter)
if(dir_panel_n > 1){
  for (i in 2:dir_panel_n) {
    new.panel = read.csv(paste0(unique_panel,'/',dir_panel[i]))
    new.panel$Chr=as.character(new.panel$Chr)
    new.panel$Start=as.character(new.panel$Start)
    new.panel$End=as.character(new.panel$End)
    new.panel$Ref=as.character(new.panel$Ref)
    new.panel$Alt=as.character(new.panel$Alt)
    new.panel$panel=as.character(new.panel$panel)
    new.panel$adapter=as.character(new.panel$adapter)
    merge.panel=rbind(merge.panel,new.panel)
  }
}
spot_marker=paste0(round_dir,'/spot_marker')
if(!dir.exists(spot_marker)){dir.create(spot_marker)}
write.csv(merge.panel,file = paste0(spot_marker,'/','spot_round.csv'),row.names=FALSE)

