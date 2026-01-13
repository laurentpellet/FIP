lstDatesFIP <- list.files(path="output/fip")
lstDatesFIP <- as.Date(substring(lstDatesFIP,11,20))
lstAllDates <- seq.Date(from=as.Date('2024-05-28'), to=as.Date("2024-08-24"), by = 1)
lstDatesManquantes <- as.character(as.Date(setdiff(lstAllDates, lstDatesFIP)))

for(dt in lstDatesManquantes) {
  cat(as.character(as.Date(dt)))
  DATA <- FIP.getSongForDay(dt)
  cat(nrow(DATA))
  cat("\n")
  fwrite(DATA, sprintf("%s/SONGS-%s-%s.csv",OUTPUTFOLDER, SOUSRADIO, as.character(dt)) , sep = ";", quote = T)
}
