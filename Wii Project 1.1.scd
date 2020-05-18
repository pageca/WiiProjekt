//Resonanz Filter Sound
(
SynthDef(\gong, {|gate = 0, freqscale = 1, freqoffset = 0, decayscale = 1,attack = 0.01, sustain = 1, release = 5,lfreq = 10, mul = 1 bpf = 400, rq = 1, pan = 0, freq, amp, decay|
	var freqs = Array.fill(8, {20 + 1000.0.rand}) * freqscale;
	var amps =  Array.fill(8, 1);
	var rings = Array.fill(8, {4 + 1.0.rand}) * decayscale;
	var env = EnvGen.ar(Env.asr(0.2, 1, release), gate, doneAction:2);
	//var env = EnvGen.ar(Env.perc(attack, release, 1),gate,doneAction:2);
	var lfo = SinOsc.ar(lfreq, 0.0, 1);
	var exciter = PinkNoise.ar(0.001 + 0.01.rand);
	var klank = DynKlank.ar(`[freqs, amps, rings], exciter, freqscale, freqoffset, decayscale) * env;
	klank = BPF.ar(klank, bpf, rq) * lfo;
	Out.ar(0, Pan2.ar(klank, pan));
}).add;
)

//B gedrückt halten, dann werden und loslassen um klang zu erzeugen und wieder b halten um ihn wieder zu "fangen"

(
x = Synth(\gong);

OSCdef(\acc, {|msg|
	~speed = msg[1];
	~spin =  msg[2];
}, "/wii/acc");

OSCdef(\orientation, {|msg|
	~leftright = msg[1];
	~updown = msg[2];
}, "/wii/orientation");

OSCdef(\ButtonB, {|msg|
	~edit = 0;
	~gate = msg[1];
	~gate.postln;
	if(~gate == 0, {
		x.set(
			\gate, 1,
			\bpf, ~spin.linlin(250, 500, 40, 2000),
			\freqscale, ~updown.linlin(-100, 100, 2, 1),
			\lfreq, ~speed.linlin(250, 500, 0, 10),
			\pan, ~leftright.linlin(-100, 100, 1,-1)
		); ~edit = 0;
	}, {x.set(\gate, 0); ~edit = 1});
}, "/wii/button/b");
)
