setwd("E:/work/")

Sys.setenv(http_proxy="http://192.168.100.3:8080")

options(warn=-1)
tMedcines = as.data.frame(cbind(
  c( "http://tab.by/result2.php?rs=1&lstr=15237&regcsv=-23"
     ,"http://tab.by/result2.php?rs=1&lstr=16046&regcsv=-23"
     ,"http://tab.by/result2.php?rs=1&lstr=16030&regcsv=-23"
     ,"http://tab.by/result2.php?rs=1&lstr=16029&regcsv=-23"
     ,"http://tab.by/result2.php?rs=1&lstr=16056&regcsv=-23"
     ,"http://tab.by/result2.php?rs=1&lstr=13106&regcsv=-23"
     ,"http://tab.by/result2.php?rs=1&lstr=13131&regcsv=-23"
  ),
  c( "detraleks"
     ,"prestance55"
     ,"prestance510"
     ,"prestance105"
     ,"prestance1010"
     ,"koraksan5"
     ,"koraksan7")))
names(tMedcines) <- c("URL", "name")

for (x in 1:length(tMedcines$URL)) {
  p2File = paste("ServierAnalytics/Minsk/",as.character(as.integer(Sys.time())),"_",tMedcines$name[x],".htm", sep = "")
  download.file(as.character(tMedcines$URL[x])
                , destfile = p2File
                , quiet = T)
  
  tbls = readHTMLTable(p2File, which = 1,
                       colClasses = list("character", NULL, NULL, NULL, NULL, NULL, "numeric",
                                         NULL, NULL, NULL))
  
  d = tbls
  names(d) <- c("name", "count")
  d$count[is.na(d$count)]<-0
  
  if (!file.exists(paste("ServierAnalytics/Minsk/",tMedcines$name[x],".csv", sep = ""))){
    file.copy("ServierAnalytics/Minsk/ChemShopNames.csv",
              paste("ServierAnalytics/Minsk/",tMedcines$name[x],".csv", sep = ""),
              overwrite = T)
  }
  p55 = read.csv(
    paste("ServierAnalytics/Minsk/",as.character(tMedcines$name[x]),".csv", sep = ""), sep = ";")
  a = as.numeric(vector(length = length(p55$name)))
  # a = vector()
  
  for(y in d$name){
    a[which(p55$name == as.character(y))] = d$count[which(d$name == as.character(y))]
  }
  
  a[is.na(a)]<-0
  
  if (!all(p55[,length(p55)] == a))
  { print(paste(tMedcines$name[x], " - Minks: Database updated!", sep = ""))
    p55 <- cbind(p55, a)
    names(p55)[length(p55)] <- as.character(as.integer(Sys.time()))
    write.table(p55, paste("ServierAnalytics/Minsk/",tMedcines$name[x],".csv", sep = ""), sep = ";", row.names = F)
  } else {
    print("Minsk: NO updates :(")
  }
}

options(warn=0)
file.remove(paste("ServierAnalytics/Minsk/",dir(path = "ServierAnalytics/Minsk/", pattern = "*.htm"), sep = ""))