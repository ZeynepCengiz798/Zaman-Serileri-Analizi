library(readxl)
Havayolutasimaciligi_1_ <- read_excel("C:/Users/zeyne/Downloads/Havayolutasimaciligi (1).xlsx")
View(Havayolutasimaciligi_1_)

baslangic_yil <- 2017
baslangic_ay <- 1

#ZAMAN SERİSİ OLARAK TANIMLANIR
TPH_ts <- ts(
  Havayolutasimaciligi_1_$TPHUFEGK18203,
  start = c(baslangic_yil, baslangic_ay),
  frequency = 12
)

#zaman serisi grafigi cizelim.
ts.plot(TPH_ts,gpars=list(xlab="Zaman", ylab="TPH"))

#ACF ve PACF grafiklerini cizdirelim:

library(forecast)

Acf(TPH_ts,lag.max = 42,  ylim=c(-1,1), lwd=3)
Pacf(TPH_ts,lag.max = 42, ylim=c(-1,1), lwd=3)

#TRENT FARKI ALINDI

Acf(diff(TPH_ts),lag.max = 42, ylim=c(-1,1), lwd=3)
Pacf(diff(TPH_ts),lag.max = 42, ylim=c(-1,1), lwd=3)


#PERİYOT ORTAYA ÇIKTI 12


Acf(diff(diff(TPH_ts),12),lag.max = 42, ylim=c(-1,1), lwd=3)
Pacf(diff(diff(TPH_ts),12),lag.max = 42, ylim=c(-1,1), lwd=3)

#SERİ DURAĞANLAŞTI

#AYRIŞTIRMA YÖNTEMLERİ

#merkezsel hareketli ortalama(toplamsal)
TPH1_ts<- ma(TPH_ts, order = 12, centre = TRUE)  #germe sayisi=12
TPH1_ts


#mevsimsel bileşen
Mevsim <- TPH_ts - TPH1_ts
Mevsim

#mevsim bileşenin içinde hata mevcuttur. hata terimini yok edebilmek için her bir periyotta dönemlerin ortalama değerleri bulunur

#Mevsim serisinin ortalamalari

donemort<-t(matrix(data=Mevsim, nrow = 12))
colMeans(donemort, na.rm = T)  #her bir periyottaki donemlerin ortalamasi
sum(colMeans(donemort, na.rm = T))  #donem ortalamalari toplami
mean(colMeans(donemort, na.rm = T)) #donem ortalamalari ortalamasi
#dönem ortalamalrı toplamı 0 a eşit değil.O yüzden ortalama değerlerinin ortalması alınır.

#mevsimsel endeks
dm<-colMeans(donemort, na.rm = T)
mean_dm<-mean(colMeans(donemort, na.rm = T))
endeks <- dm - mean_dm
endeks
indeks <- rep(endeks, length.out = length(TPH_ts))
indeks

#TREND BİLEŞENİ
trenthata <- TPH_ts - indeks
trent <- tslm(trenthata ~ trend)
summary(trent)
#TAHMİN SERİSİ

tahmin <- indeks + trent$fitted.values
tahmin 

#HATA SEİRİSİ
hata <- TPH_ts - indeks - trent$fitted.values
hata

#model uygunluğu

plot(TPH_ts, col=4, lwd=2)
lines(tahmin, col=2, lwd=2, lty=3)
legend("topleft", c("TPH_ts(t)", "Tahmin"), col=c(4,2), lwd=2, lty=c(1,3))



Acf(hata, main="Hata", lag.max=42)
Pacf(hata, main="Hata", lag.max=42)


Box.test(hata, lag=24, type="Ljung")


#ÇARPIMSAL

TPH1_ts <- ma(TPH_ts, order = 12, centre = TRUE)
TPH1_ts


Mevsim1 <- TPH_ts / TPH1_ts
Mevsim1

donemort1<-t(matrix(data=Mevsim1, nrow = 12))

dm1 <- colMeans(donemort1, na.rm = TRUE)
dm1
sum(dm1)

mean_dm1 <- mean(dm1)
mean_dm1


endeks1 <- dm1 / mean_dm1
endeks1


indeks1 <- rep(endeks1, length.out = length(TPH_ts))
indeks1


trenthata1 <- TPH_ts / indeks1


trent1 <- tslm(trenthata1 ~ trend)
trent1
summary(trent1)



tahmin1 <- indeks1 * trent1$fitted.values
tahmin1
summary(tahmin1)

hata1 <- TPH_ts - tahmin1
hata1
summary(hata1)

plot(TPH_ts, col=4, lwd=2)
lines(tahmin1, col=2, lwd=2, lty=3)
legend("topleft", c("TPH_ts(t)", "Tahmin"),
       col=c(4,2), lwd=2, lty=c(1,3))

Acf(hata1, main="Hata (Multiplicative)", lag.max=42)
Pacf(hata1, main="Hata (Multiplicative)", lag.max=42)



Box.test(hata1, lag=42, type="Ljung")



#Ayrıştırma yöntemleri ile modellenemez çünkü hata serisi akgürültü çıkmadı.



install.packages(c("forecast", "fpp2", "lmtest"))


library(fpp)
library(forecast)
library(haven)
library(lmtest)
##REGRESYON MODELLERİ
###Toplamsal model


t<-1: 1: 105   

#1.harmonik
#max 6. harmıniğe kadar gidebilirim

sin1<-sin(2*3.1416*t/12)
cos1<-cos(2*3.1416*t/12)



veriseti<-as.data.frame(cbind(TPH_ts,t,sin1,cos1))
names(veriseti)<- c("y", "t", "sin1", "cos1")
attach(veriseti)

model2 <- lm(TPH_ts ~ t + sin1 + cos1, data = veriseti)
regresyon.model2<-lm(TPH_ts~t+sin1+cos1)
summary(regresyon.model2)


#katsaılar anlamsız çıktı 0.05ten büyük 2.harmoniğe geçemem.


###Carpımsal model

s1<-t*sin(2*3.1416*t/12)

c1<-t*cos(2*3.1416*t/12)


veriseti3<-as.data.frame(cbind(TPH_ts, t, s1, c1))

names(veriseti3)<- c("y", "t", "s1", "c1")
attach(veriseti3)



model3<-lm(TPH_ts~t+s1+c1,data=veriseti3)
regresyon.model3<-lm(TPH_ts~t+s1+c1,data=veriseti3)
summary(regresyon.model3)


s2<-t*sin(2*3.1416*2*t/12)
c2<-t*cos(2*3.1416*2*t/12)


veriseti4<-as.data.frame(cbind(TPH_ts, t, s1, c1, s2, c2))
names(veriseti4)<- c("y", "t", "s1", "c1", "s2", "c2")


attach(veriseti4)

model4<-lm(TPH_ts~t+s1+c1+s2+c2,data=veriseti4)
regresyon.model4<-lm(TPH_ts~t+s1+c1+s2+c2,data=veriseti4)
summary(regresyon.model4)

#s2 ve c2 anlamsD1z, modelde sadece t, c1, s1 yer alir. Tekrar 3.modele donuyoruz.

##durbin-watson testi

dwtest(TPH_ts~t+s1+c1)



#dw 0.072 old için hata serisi akgürültü çıkmaz diyebiliriz.


#3.model icin tahmin serisi, hata serisi ve tahminin alt ve C<st sD1nD1rlarD1na ait seriler

tahmin3<-predict(regresyon.model3)
sinir3<-predict(regresyon.model3, interval = 'confidence' ,level = .95)
hata3<-resid(regresyon.model3)




plot( window(y),
      xlab="", ylab="", type="l", lty=3, col=2, lwd=2)
lines(window(tahmin3), type="l", lty=1, col=1, lwd=2)
lines(window(sinir3[,2]) ,type="l",lty=1,col=4,lwd=2)
lines(window(sinir3[,3]) ,type="l",lty=1,col=3,lwd=2)
legend("topleft",
       c(expression(paste(TPH_ts)),
         expression(paste(Altsinir)),
         expression(paste(ustsinir)),
         expression(paste(Tahmin3))),
       lwd=c(2,2,2,2),
       lty=c(3,1,1,1),
       cex=0.7,
       col=c(2,4,3,1))

#Hatalar akgurultu mu?

Acf(hata3,lag.max = 42,  ylim=c(-1,1), lwd=3)

Pacf(hata3,lag.max = 42,  ylim=c(-1,1), lwd=3)

#Box-Ljung

Box.test(hata3, lag = 24, type = "Ljung")


#REGRESYON YÖNTEMİYLE MODELLENEMEZ.

#ÜSTEL DÜZLEŞTİRME YÖNTEMLERİ
## Toplamsal Winters Yontemi ##
###############################

Winters1<- ets(TPH_ts, model = "AAA")
summary(Winters1)


tahmin4<- Winters1[["fitted"]]


plot( window(TPH_ts), 
      xlab="Zaman", ylab="",lty=1, col=4, lwd=2)
lines( window(tahmin4) ,lty=3,col=2,lwd=3)
legend("topleft",c(expression(paste(Orjinalseri)),
                   expression(paste(Winters1Tahmin))),
       lwd=c(2,2),lty=c(1,3), cex=0.7, col=c(4,2))


hata4<- Winters1[["residuals"]]
Acf(hata4,main="Hata", lag.max = 42,  ylim=c(-1,1), lwd=3)
Pacf(hata4,main="Hata",lag.max = 42, ylim=c(-1,1), lwd=3)


Box.test (hata4, lag = 42, type = "Ljung")



##############################
## Carpimsal Winters Yontemi ##
##############################

Winters2<- ets(TPH_ts, model = "MAM")
summary(Winters2)



tahmin5<- Winters2[["fitted"]]

plot( window(TPH_ts), 
      xlab="Zaman", ylab="",lty=1, col=4, lwd=2)
lines( window(tahmin5) ,lty=3,col=2,lwd=3)
legend("topleft",c(expression(paste(Orjinalseri)),
                   expression(paste(Winters2Tahmin))),
       lwd=c(2,2),lty=c(1,3), cex=0.7, col=c(4,2))


hata5<- Winters2[["residuals"]]
Acf(hata5,main="Hata", lag.max = 24,  ylim=c(-1,1), lwd=3)
Pacf(hata5,main="Hata",lag.max = 24, ylim=c(-1,1), lwd=3)


Box.test (hata5, lag = 24, type = "Ljung")






checkresiduals(Winters2, lag = 24)

ongoru <- forecast(Winters2,h=5)

ongoru[["mean"]]



ongoru<- forecast(Winters2 , h=5)

ongoru

ongoru_mean<-ongoru[["mean"]]
ongoru1<-as.data.frame(ongoru[["mean"]])
ongoru1<-cbind(c("2025-10","2025-11","2025-12","2026-01","2026-02"),ongoru1)
names(ongoru1)<-c("Dönem","Ongörü")
ongoru1



summary(Winters2)



##BOX JENKINS MODELLERİ

TPH_ts_arima1 <- Arima(TPH_ts, order = c(1,1,0), seasonal= c(0,1,0), include.constant=TRUE)
coeftest(TPH_ts_arima1)
summary(TPH_ts_arima1)




TPH_ts_arima2 <- Arima(TPH_ts, order = c(1,1,0), seasonal= c(1,1,0), include.constant=TRUE)
coeftest(TPH_ts_arima2)
summary(TPH_ts_arima2)


TPH_ts_arima3 <- Arima(TPH_ts, order = c(1,1,0), seasonal= c(0,1,1), include.constant=TRUE)
coeftest(TPH_ts_arima3)
summary(TPH_ts_arima3)

TPH_ts_arima4 <- Arima(TPH_ts, order = c(1,1,0), seasonal= c(1,1,1), include.constant=TRUE)
coeftest(TPH_ts_arima4)
summary(TPH_ts_arima4)

TPH_ts_arima5 <- Arima(TPH_ts, order = c(0,1,1), seasonal= c(1,1,0), include.constant=TRUE)
coeftest(TPH_ts_arima5)
summary(TPH_ts_arima5)

TPH_ts_arima6 <- Arima(TPH_ts, order = c(0,1,1), seasonal= c(0,1,0), include.constant=TRUE)
coeftest(TPH_ts_arima6)
summary(TPH_ts_arima6)


TPH_ts_arima7 <- Arima(TPH_ts, order = c(0,1,1), seasonal= c(0,1,1), include.constant=TRUE)
coeftest(TPH_ts_arima7)
summary(TPH_ts_arima7)


TPH_ts_arima8 <- Arima(TPH_ts, order = c(0,1,1), seasonal= c(1,1,1), include.constant=TRUE)
coeftest(TPH_ts_arima8)
summary(TPH_ts_arima8)



TPH_ts_arima9 <- Arima(TPH_ts, order = c(1,1,1), seasonal= c(1,1,0), include.constant=TRUE)
coeftest(TPH_ts_arima9)
summary(TPH_ts_arima9)

TPH_ts_arima10 <- Arima(TPH_ts, order = c(1,1,1), seasonal= c(0,1,1), include.constant=TRUE)
coeftest(TPH_ts_arima10)
summary(TPH_ts_arima10)

TPH_ts_arima11 <- Arima(TPH_ts, order = c(1,1,1), seasonal= c(0,1,0), include.constant=TRUE)
coeftest(TPH_ts_arima11)
summary(TPH_ts_arima11)


TPH_ts_arima12 <- Arima(TPH_ts, order = c(1,1,1), seasonal= c(1,1,1), include.constant=TRUE)
coeftest(TPH_ts_arima12)
summary(TPH_ts_arima12)

TPH_ts_arima13 <- Arima(TPH_ts, order = c(0,1,0), seasonal= c(0,1,1), include.constant=TRUE)
coeftest(TPH_ts_arima13)
summary(TPH_ts_arima13)

TPH_ts_arima14 <- Arima(TPH_ts, order = c(0,1,0), seasonal= c(1,1,0), include.constant=TRUE)
coeftest(TPH_ts_arima14)
summary(TPH_ts_arima14)

TPH_ts_arima15 <- Arima(TPH_ts, order = c(0,1,0), seasonal= c(1,1,1), include.constant=TRUE)
coeftest(TPH_ts_arima15)
summary(TPH_ts_arima15)



tahmin<- TPH_ts_arima1[["fitted"]]
hata<- TPH_ts_arima1[["residuals"]]

plot( window(TPH_ts), 
      xlab="Zaman (Yil)", ylab="",lty=1, col=4, lwd=2)
lines( window(tahmin) ,lty=3,col=2,lwd=3)
legend("topleft",c(expression(paste(TPH_ts)),
                   expression(paste(Tahmin))),
       lwd=c(2,2),lty=c(1,3), cex=0.7, col=c(4,2))


Box.test (hata, lag = 42, type = "Ljung")



Acf(hata,main="Hata", lag.max = 42,  ylim=c(-1,1), lwd=3)
Pacf(hata,main="Hata",lag.max = 42, ylim=c(-1,1), lwd=3)


ongoru<- forecast(TPH_ts_arima1 , h=5)

ongoru

ongoru_mean<-ongoru[["mean"]]
ongoru2<-as.data.frame(ongoru[["mean"]])
ongoru2<-cbind(c("2025-10","2025-11","2025-12","2026-01","2026-02"),ongoru2)
names(ongoru2)<-c("Dönem","Ongörü")

ongoru2




checkresiduals(TPH_ts_arima1)










































