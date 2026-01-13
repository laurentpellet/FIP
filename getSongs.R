source("functions.R")

#SOUSRADIO <- "radio-reggae"  #fip, radio-reggae, radio-jazz
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
DATA[,start:=as.POSIXct(start)]
DATA[,end:=as.POSIXct(end)]
saveRDS(DATA, file=sprintf("output/SONGS-%s-2024.rds",  SOUSRADIO))

## ECRITURE D'UN FICHIER PAR MOIS
DATA[, mois:=sprintf("%04d-%02d", year(start),month(start))]
lstMois <- DATA[, .N, mois][,mois]
lapply(lstMois, FUN=function(x) {
  fwrite(DATA[mois==x,.(SOUNDIIZ=sprintf("%s - %s", Artist, Song))], sprintf("output/soundiiz/FIP-%s-%s.csv", SOUSRADIO, x))
  #fwrite(DATA[mois==x & itunes!="",.(SOUNDIIZ=sprintf("%s - %s", Artist, Song))], sprintf("output/soundiiz/FIP-%s-%s.csv", SOUSRADIO, x))
  
})

## ANALYSE
FIP <-  readRDS("output/SONGS-fip-2024.rds")
FIP.JAZZ <-  readRDS("output/SONGS-radio-jazz-2024.rds")
FIP.REGGAE <-  readRDS("output/SONGS-radio-reggae-2024.rds")
SONGS <- rbindlist(list(FIP, FIP.JAZZ, FIP.REGGAE), use.names = T , fill=T)

FIP.REGGAE[, .N, Artist][order(-N)][1:20]
FIP[, .N, Artist][order(-N)][1:20]

DATA[, .N, Artist][order(-N)][1:20]
