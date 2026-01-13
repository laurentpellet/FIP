js <- FIP.getSongs(NULL)
js$songs

DATA <- fread("output/fip/SONGS-fip-2024-05-25")

fwrite(DATA[order(start)][,.(SOUNDIIZ=paste(Artist, Song, sep=" - "))], sprintf("output/soundiiz/FIP-%s.csv", SOUSRADIO))
fwrite(DATA[order(start)][itunes!="",.(SOUNDIIZ=paste(Artist, Song, sep=" - "))], sprintf("output/soundiiz/FIP-itunesonly-%s.csv", SOUSRADIO))

DATA[, mois:=sprintf("%04d-%02d", year(start),month(start))]
lstMois <- DATA[, .N, mois][,mois]
lapply(lstMois, FUN=function(x) {
  fwrite(DATA[mois==x & itunes!="",.(SOUNDIIZ=paste(Artist, Song, sep=" - "))], sprintf("output/soundiiz/FIP-itunes-%s-%s.csv", SOUSRADIO, x))
})


fwrite(DATA[itunes!="",.(SOUNDIIZ=sprintf("%s",itunes))][1:200], "testImport.csv", sep=";")


fwrite(DATA[mois==x & !is.na(itunes)],.(SOUNDIIZ=paste(Artist, Song, sep=" - "))], sprintf("output/soundiiz/FIP-%s-%s.csv", SOUSRADIO, x))
