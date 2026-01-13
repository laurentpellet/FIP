source("functions.R")

SOUSRADIO <- "fip"  #fip, radio-reggae, radio-jazz
URL <- sprintf("https://www.radiofrance.fr/fip/%s/api/songs", SOUSRADIO)
OUTPUTFOLDER <- sprintf("output/%s", SOUSRADIO)

## APPELS API
dt <- as.Date('2025-01-02')
dt <- Sys.Date()
for(i in 0:90) {
  cat(as.character(dt+i))
  DATA <- FIP.getSongForDay(dt+i)
  cat(nrow(DATA))
  cat("\n")
  fwrite(DATA, sprintf("%s/SONGS-%s-%s.csv",OUTPUTFOLDER, SOUSRADIO, as.character(dt+i)) , sep = ";", quote = T)
}


## CONSOLIDATIONS
DATA <- unique(rbindlist(lapply(list.files(OUTPUTFOLDER, pattern="*.csv", full.names = T), fread), use.names = T, fill=T))
DATA[, start:=as.POSIXct(start)]
DATA[, end:=as.POSIXct(end)]
DATA[, mois:=sprintf("%04d-%02d", year(start),month(start))]
DATA[, week:=isoweek(start)]
saveRDS(DATA, file=sprintf("output/SONGS-%s.rds",  SOUSRADIO))


## ECRITURE D'UN FICHIER PAR MOIS
lstMois <- DATA[, .N, mois][,mois]
lapply(lstMois, FUN=function(x) {
  fwrite(DATA[mois==x,.(SOUNDIIZ=sprintf("%s - %s", Artist, Song))], sprintf("output/soundiiz/FIP-%s-%s.csv", SOUSRADIO, x))
  #fwrite(DATA[mois==x & itunes!="",.(SOUNDIIZ=sprintf("%s - %s", Artist, Song))], sprintf("output/soundiiz/FIP-%s-%s.csv", SOUSRADIO, x))
  
})

lstWeek <- DATA[year(start)==2024, .N, week][,week]
lapply(lstWeek, FUN=function(x) {
  fwrite(DATA[week==x,.(SOUNDIIZ=sprintf("%s - %s", Artist, Song))], sprintf("output/soundiiz/FIP-2024-%s-2024W%02d.csv", SOUSRADIO, x), col.names = F)
  #fwrite(DATA[mois==x & itunes!="",.(SOUNDIIZ=sprintf("%s - %s", Artist, Song))], sprintf("output/soundiiz/FIP-%s-%s.csv", SOUSRADIO, x))
  
})

