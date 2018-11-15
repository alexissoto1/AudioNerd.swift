<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

ga1 init 0

instr 1

kaccelX chnget "accelerometerX"
kaccelY chnget "accelerometerY"
kaccelZ chnget "accelerometerZ"

kgyroX chnget "gyroX"
kgyroY chnget "gyroY"
kgyroZ chnget "gyroZ"

kattRoll chnget "attitudeRoll"
kattPitch chnget "attitudePitch"
kattYaw chnget "attitudeYaw"

kcutoff = 5000 + (4000 * kaccelX)
kresonance = .3 + (.4  * kaccelY)
kpch = 880 + kaccelX * 220

a1 vco2 (kaccelZ + .5)  * .2, kpch
a1 moogladder a1, kcutoff, kresonance
aL, aR reverbsc a1, a1, .72, 5000
outs aL, aR
endin

instr 2

kaccelX2 chnget "accelerometerX"
kaccelY2 chnget "accelerometerY"
kaccelZ2 chnget "accelerometerZ"

kgyroX2 chnget "gyroX"
kgyroY2 chnget "gyroY"
kgyroZ2 chnget "gyroZ"

kattRoll2 chnget "attitudeRoll"
kattPitch2 chnget "attitudePitch"
kattYaw2 chnget "attitudeYaw"

kcutoff = 7000 + (4000 * kaccelX2)
kresonance = .4 + (.4  * kaccelY2)
kpch = 880 + kaccelX2 * 220

a1 vco2 (kaccelZ2 + .3)  * .2, kpch
a1 moogladder a1, kcutoff, kresonance
aL, aR reverbsc a1, a1, .72, 5000
outs aL, aR
endin

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>

