[English version](https://github-com.translate.goog/haykonus/KC85-Demos?_x_tr_sl=de&_x_tr_tl=en&_x_tr_hl=de&_x_tr_pto=wapp)
# INHALT

[GleEst für KC85/4](https://github.com/haykonus/KC85-Demos/blob/main/README.md#gleest-f%C3%BCr-kc854)

<br>

# GleEst für KC85/4

![Demo](/GleEst_KC85-4/Bilder/gleest_KC85-4.gif)

Dieses Programm für den [KC85/4](http://www.mpm-kc85.de/html/D001BasisDevise.htm) basiert auf [GleEst](https://zxart.ee/eng/software/demoscene/intro/256b-intro/gleest/) für den ZX-Spectrum, programmiert von Oleg Senin (bfox, St.Petersburg, Russia). Seine 256 Byte-Demo enthält im Original noch eine Sound-Ausgabe über den AY-3-8912 und setzt die Farb-Attribute des ZX-Spectrum. Der Algorithmus wurde extrahiert, leicht modifiziert (RAM-Speicherbedarf optimiert) und der Grafik-Effekt, inkl. Farben, an den KC85/4 angepasst. Der Sound-Effekt ist nicht implementiert, da der KC85/4 keinen Sound-Chip der AY-3-Familie besitzt.

Zum Assemblieren wurde der [Arnold-Assembler](http://john.ccac.rwth-aachen.de:8000/as/) unter Windows 11 verwendet.

## Vorausetzungen

- KC85/4
- oder [JKCEMU](http://www.jens-mueller.org/jkcemu/index.html)

## Schnellstart
> [!CAUTION]
> Die Links unten anklicken und danach den Download-Button (Download raw file) im Github klicken, um die Datei zu laden.

- [gleest_KC85-4_0200H.bin](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-4/gleest_KC85-4_0200H.bin)
- auf Adresse 0200H laden
- mit MENU / GLEEST starten
  
oder

- [gleest_KC85-4_0200H.kcc](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-4/gleest_KC85-4_0200H.kcc) laden
- mit MENU / GLEEST starten, oder Autostart

oder

- [gleest_KC85-4_0200H.wav](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-4/gleest_KC85-4_0200H.wav)
- mit LOAD laden (Autostart)


> [!TIP]
> Das Programm kann mit Drücken einer beliebigen Taste beendet werden.


## Quellen

Dieses Projekt nutzt Infos und Software aus den u.g. Quellen. Besonderer Dank an Mario Leubner für das herrvoragende KC85/5 Systemhandbuch.

http://kc85.info/

http://www.mpm-kc85.de/html/D001BasisDevise.htm

http://www.kc85.info/index.php/download.html?view=download&id=401:kc85-5-systemhandbuch&catid=32

https://zxart.ee/eng/software/demoscene/intro/256b-intro/gleest/

http://www.primrosebank.net/computers/zxspectrum/docs/CompleteSpectrumROMDisassemblyThe.pdf

