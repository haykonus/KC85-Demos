[English version](https://github-com.translate.goog/haykonus/KC85-Demos?_x_tr_sl=de&_x_tr_tl=en&_x_tr_hl=de&_x_tr_pto=wapp)
# INHALT


[GleEst für KC85/1 KRT](https://github.com/haykonus/KC85-Demos/blob/main/README.md#gleest-f%C3%BCr-kc851)

[GleEst für KC85/3/4](https://github.com/haykonus/KC85-Demos/blob/main/README.md#gleest-f%C3%BCr-kc8534)


# GleEst für KC85/1/3/4

Dieses Programm für den [KC85/1](https://www.robotrontechnik.de/index.htm?/html/computer/kc_dresden.htm) mit [KRT-Grafik](https://hc-ddr.hucki.net/wiki/doku.php/z9001/erweiterungen/krtgrafik) und [KC85/3](http://www.mpm-kc85.de/html/d001_kc85_3.htm) / [KC85/4](http://www.mpm-kc85.de/html/D001BasisDevise.htm) basiert auf [GleEst](https://zxart.ee/eng/software/demoscene/intro/256b-intro/gleest/) für den ZX-Spectrum 128, programmiert von Oleg Senin (bfox, St.Petersburg, Russia). Seine 256 Byte-Demo enthält im Original noch eine Sound-Ausgabe über den AY-3-8912 und setzt die Farb-Attribute des ZX-Spectrum. Der Algorithmus wurde extrahiert, leicht modifiziert (RAM-Speicherbedarf optimiert) und der Grafik-Effekt, inkl. Farben, an den KC85/1/3/4 angepasst. Das Programm läuft im [JKCEMU](http://www.jens-mueller.org/jkcemu/index.html) auch auf dem Z9001/KC87 mit [KRT-Grafik](https://hc-ddr.hucki.net/wiki/doku.php/z9001/erweiterungen/krtgrafik) sowie dem HC900, dem KC85/2 und dem KC85/5.

Der Sound-Effekt ist nicht implementiert, da die KC85/1/3/4 keinen Sound-Chip der AY-3-Familie besitzen. Es gibt jedoch das Zusatz-Modul [M066](http://kc85.info/index.php/steckmodule-mxxx/256-m066-ein-soundmodul-fuer-den-kc85.html) ([Handbuch](http://kc85.info/index.php/download.html?view=download&id=362:m066-handbuch&catid=32)) für den KC85/3/4 mit dem AY-3-8910. In einer späteren Version könnte der Sound-Effekt dort noch implementiert werden. 

Zum Assemblieren wurde der [Arnold-Assembler](http://john.ccac.rwth-aachen.de:8000/as/) unter Windows 11 verwendet.

> [!TIP]
> Das Programm kann mit Drücken einer beliebigen Taste beendet werden.

<br>

## GleEst für KC85/1

![Demo](/GleEst_KC85-1_KRT/Bilder/gleest_KC85-1_KRT.gif)

### Vorausetzungen

- KC85/1, Z9001 oder KC87 mit [KRT-Grafik](https://hc-ddr.hucki.net/wiki/doku.php/z9001/erweiterungen/krtgrafik)
- oder [JKCEMU](http://www.jens-mueller.org/jkcemu/index.html)

### Schnellstart

> [!CAUTION]
> Die Links unten anklicken und danach den Download-Button (Download raw file) im Github klicken, um die Datei zu laden.

- [gleest_KC85-1_KRT_0300H.bin](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-1_KRT/gleest_KC85-1_KRT_0300H.bin)
- [gleest_KC85-1_KRT_0300H.kcc](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-1_KRT/gleest_KC85-1_KRT_0300H.kcc)

Auf Adresse 0300H laden und mit GLEEST1 starten, oder Autostart.

<br>

## GleEst für KC85/4

![Demo](/GleEst_KC85-4/Bilder/gleest_KC85-4.gif)

### Vorausetzungen

- KC85/4 oder KC85/5
- oder [JKCEMU](http://www.jens-mueller.org/jkcemu/index.html)

### Schnellstart

> [!CAUTION]
> Die Links unten anklicken und danach den Download-Button (Download raw file) im Github klicken, um die Datei zu laden.

- [gleest_KC85-4_0200H.bin](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-4/gleest_KC85-4_0200H.bin)
- [gleest_KC85-4_0200H.kcc](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-4/gleest_KC85-4_0200H.kcc)
- [gleest_KC85-4_0200H.wav](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-4/gleest_KC85-4_0200H.wav)

Auf Adresse 0200H laden, mit MENU / GLEEST4 starten, oder Autostart.

### GleEst als Bildschirmschoner

Für den KC85/4 wurde GleEst auch als Bildschirmschoner unter CAOS implementiert:

https://gitlab.com/stefan_koch/gleest-screensaver/

<br>

## GleEst für KC85/3

![Demo](/GleEst_KC85-3/Bilder/gleest_KC85-3.gif)

### Vorausetzungen

- KC85/3, KC85/2 oder HC900
- oder [JKCEMU](http://www.jens-mueller.org/jkcemu/index.html)

### Schnellstart

> [!CAUTION]
> Die Links unten anklicken und danach den Download-Button (Download raw file) im Github klicken, um die Datei zu laden.

- [gleest_KC85-3_0200H.bin](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-3/gleest_KC85-3_0200H.bin)
- [gleest_KC85-3_0200H.kcc](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-3/gleest_KC85-3_0200H.kcc)
- [gleest_KC85-3_0200H.wav](https://github.com/haykonus/KC85-Demos/blob/main/GleEst_KC85-3/gleest_KC85-3_0200H.wav)

Auf Adresse 0200H laden, mit MENU / GLEEST3 starten, oder Autostart.

<br>

## Quellen

Dieses Projekt nutzt Infos und Software aus den u.g. Quellen. Besonderer Dank geht an Mario Leubner für das hervorragende KC85/5 Systemhandbuch, sowie an KaiOr und Crawler aus dem [Robotrontechnik-Forum](https://www.robotrontechnik.de/html/forum/thwb/index.php) für Tipps und Code-Optimierungen. 

http://kc85.info/

http://www.sax.de/~zander/z9001/ex/80z.html

https://hc-ddr.hucki.net/wiki/doku.php/z9001/erweiterungen/krtgrafik

http://www.mpm-kc85.de/html/D001BasisDevise.htm

http://www.kc85.info/index.php/download.html?view=download&id=401:kc85-5-systemhandbuch&catid=32

https://zxart.ee/eng/software/demoscene/intro/256b-intro/gleest/

http://www.primrosebank.net/computers/zxspectrum/docs/CompleteSpectrumROMDisassemblyThe.pdf

