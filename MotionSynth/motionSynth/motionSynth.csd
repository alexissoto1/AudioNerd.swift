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

kaccelX chnget "accelerometerX"
kaccelY chnget "accelerometerY"
kaccelZ chnget "accelerometerZ"

kgyroX chnget "gyroX"
kgyroY chnget "gyroY"
kgyroZ chnget "gyroZ"

kattRoll chnget "attitudeRoll"
kattPitch chnget "attitudePitch"
kattYaw chnget "attitudeYaw"

kcutoff = 7000 + (4000 * kaccelX)
kresonance = .4 + (.4  * kaccelY)
kpch = 880 + kaccelX * 220

a1 vco2 (kaccelZ + .5)  * .2, kpch
a1 moogladder a1, kcutoff, kresonance
aL, aR reverbsc a1, a1, .72, 5000
outs aL, aR
endin

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
