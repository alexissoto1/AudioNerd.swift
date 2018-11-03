<CsoundSynthesizer>
<CsOptions>
-i adc
-o dac
-d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 10
nchnls = 2
0dbfs = 1.0

maxalloc 5,4

instr 1
kdst        chnget    "dist"
krvb        chnget    "verb"
kamp        chnget  "levl"

kdst        port        kdst, .001
krvb        port        krvb,  .001
kamp        port        kamp,  .001

ainL, ainR ins
avL, avR    reverbsc    ainL,    ainR,    0.6,            12000
adL distort1 ainL, 2, 0.5, 0, 0
adR distort1 ainR, 2, 0.5, 0, 0

outs (((adL * kdst) + (avL * krvb)) + ainL) * (kamp/3), (((adR * kdst) + (avR * krvb)) + ainR) * (kamp/3)
endin

instr 2
kamp1       chnget    "vol1"
kamp1        port       kamp1, .001
kenv        linsegr        0,          .001,         1,      .01,     1,     .1, 0
asig        oscil        kenv,        cpsmidinn(p4),        p5
outs        asig*kamp1,        asig*kamp1
endin

</CsInstruments>
<CsScore>
f0 z
f1 0         16384 10 1

</CsScore>
</CsoundSynthesizer>

