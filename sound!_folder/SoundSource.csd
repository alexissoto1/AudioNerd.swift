<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1.0

maxalloc 1, 1
maxalloc 2, 1
maxalloc 3, 1
maxalloc 4, 1

;sine wave
instr 1

kfreq chnget "freq"
kport port kfreq, 0.01

kvol chnget "vol"
kvport port kvol, 0.01

a1 oscil kvport, kport
outs a1, a1
endin

;square wave
instr 2
kfreq chnget "freq"
kport port kfreq, 0.01

kvol chnget "vol"
kvport port kvol, 0.01

a2 oscil kvport, kport, 2
outs a2, a2
endin

;pulse wave
instr 3

kfreq chnget "freq"
kport port kfreq, 0.01

kvol chnget "vol"
kvport port kvol, 0.01

a3 oscil kvport, kport, 3
outs a3, a3
endin

;"Some wave"
instr 4

kfreq chnget "freq"
kport port kfreq, 0.01

kvol chnget "vol"
kvport port kvol, 0.01

a4 oscil kvport, kport, 4
outs a4, a4
endin

instr 99
turnoff2 p4, 0, 0
endin

instr 199
;dummy instrument to start csound
endin

</CsInstruments>
<CsScore>

;square wave
f2 0 4096 10 1 0 .333 0 .2 0 .14

;pulse wave
f3 0 1024 10 1 1 1 1 0.7 0.5 0.3 0.1

;"Some" wave
f4 0 1024 10 1 1 1 1 1 1 1 1 1 1

i199 0 10000
</CsScore>
</CsoundSynthesizer>
