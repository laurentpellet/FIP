source("functions.R")

#SOUSRADIO <- "radio-reggae"  #fip, radio-reggae, radio-jazz
SOUSRADIO <- "fip"  #fip, radio-reggae, radio-jazz
URL <- sprintf("https://www.radiofrance.fr/fip/%s/api/songs", SOUSRADIO)
OUTPUTFOLDER <- sprintf("output/%s", SOUSRADIO)

## APPELS API
dt <- as.Date('2026-01-31')
#dt <- Sys.Date()
for(i in 0:5) {
  cat(as.character(dt+i))
  DATA <- FIP.getSongForDay(dt+i)
  cat(nrow(DATA))
  cat("\n")
  fwrite(DATA, sprintf("%s/SONGS-%s-%s.csv",OUTPUTFOLDER, SOUSRADIO, as.character(dt+i)) , sep = ";", quote = T)
}

## CONSOLIDATIONS
DATA <- unique(rbindlist(lapply(list.files(OUTPUTFOLDER, pattern=".csv", full.names = T), fread), use.names = T, fill=T))
DATA[,start:=as.POSIXct(start)]
DATA[,end:=as.POSIXct(end)]
saveRDS(DATA, file=sprintf("output/SONGS-%s.rds",  SOUSRADIO))
saveRDS(DATA[year(start)==2024], file=sprintf("output/SONGS-%s-2024.rds",  SOUSRADIO))
saveRDS(DATA[year(start)==2025], file=sprintf("output/SONGS-%s-2025.rds",  SOUSRADIO))
saveRDS(DATA[year(start)==2026], file=sprintf("output/SONGS-%s-2026.rds",  SOUSRADIO))

## ECRITURE D'UN FICHIER PAR MOIS
DATA <- readRDS("output/SONGS-fip.rds")
DATA[, YW :=sprintf("%04dW%02d", year(start),isoweek(start))]

lapply(DATA[, unique(YW)], FUN=function(x) {
  fwrite(
    DATA[YW==x,.(SOUNDIIZ=sprintf("%s - %s", Artist, Song))],
    sprintf("output/soundiiz/FIP-%s-%s.csv", SOUSRADIO, x))
})

## ANALYSE
FIP <-  readRDS("output/SONGS-fip-2024.rds")
FIP.JAZZ <-  readRDS("output/SONGS-radio-jazz-2024.rds")
FIP.REGGAE <-  readRDS("output/SONGS-radio-reggae-2024.rds")
SONGS <- rbindlist(list(FIP, FIP.JAZZ, FIP.REGGAE), use.names = T , fill=T)

FIP.REGGAE[, .N, Artist][order(-N)][1:20]
FIP[, .N, Artist][order(-N)][1:20]

DATA[year(start)==2026, .N, Artist][order(-N)][1:20]
DATA[Year>=2020, .N, Artist][order(-N)][1:20]
DATA[Artist=='Voyou', .N, Album]


DATA[, .N, itunes][order(-N)][1:20]
DATA[deezer=='https://www.deezer.com/track/2964593791']
summary(DATA)


