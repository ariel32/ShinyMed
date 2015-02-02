library("RSQLite")

db = dbConnect(SQLite(), dbname="db.sqlite")
dbSendQuery(conn = db,
            "CREATE TABLE data
            (ID INTEGER PRIMARY KEY,
            CSname TEXT,
            time NUM,
            medicine TEXT,
            quantity INTEGER)")
dbSendQuery(conn = db, "CREATE TABLE chemshop 
            (ID INTEGER PRIMARY KEY,
            CSname TEXT UNIQUE,
            address TEXT,
            lon REAL,
            lat REAL)")


dbSendQuery(conn = db, "INSERT INTO data (CSname, time, medicine, quantity) VALUES('CS2', 11231233, 'pred', 2)")
dbSendQuery(conn = db, "DROP TABLE chemshop")

dbListTables(db)
dbListFields(db, "data")
head(dbReadTable(db, "data"))

dbReadTable(db, "chemshop") -> dt
dbReadTable(db, "data") -> cst

dbDisconnect(db)

# обновляем АПТЕКИ
i = 0
for(x in dir("data")) {
  d = read.csv(paste("data/",x, sep = "")
               , sep = ",")
  for(y in 1:length(d$pharmacy)) {
    d.cs = d$pharmacy
    d.add = d$pharmacy_cnt
    dt <- dbReadTable(db, "chemshop")
    if(length(which(dt$CSname == d.cs[y])) == 0) {
      query = paste("INSERT INTO chemshop (CSname, address) VALUES ('", d.cs[y],"','", d.add[y], "')", sep = "")
      dbSendQuery(conn = db, query)
    }
    print(i); i = i+1
  }
}

# заполняем данные о ЛС
i = 0
for(x in dir("data")){
  d = read.csv(paste("data/",x, sep = "")
               , sep = ",")
  for(y in 1:length(d$medicine)) {
    query = paste("INSERT INTO data (CSname, time, medicine, quantity) VALUES
                ('",d$pharmacy[y],"',
                '",strsplit(x, "\\.")[[1]][1],"',
                '",d$medicine[y],"',
                '",d$quantity[y],"')"
                  ,sep = "")
    dbSendQuery(conn = db, query)
  }
  print(i); i = i+1
}




for (x in dt$ID){
  query = paste("UPDATE chemshop SET address ='",substr(dt$address[x],1, nchar(dt$address[x])-1),"' WHERE ID ='",x,"'"
                ,sep = "")
  dbSendQuery(conn = db, query)
}


  ####### получаем координаты

library(XML); library(rjson)
aaa = dbGetQuery(conn = db, "SELECT * FROM chemshop")
aaa3 = vector()
for(x in aaa$address) {
  url = paste("http://geocode-maps.yandex.ru/1.x/?format=json&geocode=",
              x
              ,sep = "")
  aaa2 = fromJSON(getURL(url))
  aaa3 = append(aaa3, aaa2$response$GeoObjectCollection$featureMember[[1]]$GeoObject$Point$pos)
}

for(x in 1:length(aaa3)) {
  dbSendQuery(conn = db, paste("INSERT INTO chemshop (CSname, address, lon, lat) VALUES (
              '",aaa$CSname[x],"',
              '",aaa$address[x],"',
              '",aaa3[[x]][1],"',
              '",aaa3[[x]][2],"')", sep = ""))
}





