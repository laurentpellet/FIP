library(httr2)
library(data.table)
library(openxlsx2)

FIP.getSongs <- function(ts, curs=NULL) {
  req <- request(URL) %>% req_url_query(timestamp=ts)
  if(!is.null(curs))
    req <- req %>% req_url_query(pageCursor=curs)
  resp <- req_perform(req)
  songs <- resp |> resp_body_json() 
  songs
}

FIP.jsonLineToDT <- function(x) {
  A <- data.table(Artist=x$firstLine,
                  Album=x$release$title,
                  Song=x$secondLine,
                  Year=x$release$year,
                  Label=x$release$label,
                  start=x$start,
                  end=x$end)
  
  if(length(x$links)>0){
    DTLinks <- as.data.table(matrix(unlist(x$links), nrow = 2))
    colnames(DTLinks) <- as.character(DTLinks[1])
    DTLinks <- DTLinks[-1]
    A <- cbind(A, DTLinks)
  }
  A
}

FIP.jsonToDT <- function(js){
  rbindlist(lapply(1:length(js$songs), FUN=function(i) FIP.jsonLineToDT(js$songs[[i]])), fill=T)
}

FIP.getSongForDay <- function(date){
  i <- 1
  curs <- NULL
  ts <- as.numeric(as.POSIXct(date)+10*3600)
  
  js <- FIP.getSongs(ts, curs)
  DATA <- FIP.jsonToDT(js)
  curs <- js$`next`
  
  while(!is.null(curs) & js$songs[[1]]$end<=ts+24*3600) {
    cat(curs)
    js <- FIP.getSongs(ts, curs)
    if(length(js$songs)>0){
      DATA2 <- FIP.jsonToDT(js)
      DATA <- rbind(DATA, DATA2, fill=T)
    }
    curs <- js$`next`
  }
  DATA[,start:=as.POSIXct(start, tz="Pacific/Tahiti")]
  DATA[,end:=as.POSIXct(end, tz="Pacific/Tahiti")]
  
  DATA
}
