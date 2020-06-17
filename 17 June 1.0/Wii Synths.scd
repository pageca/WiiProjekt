(
~run = 0;
~bufbus = Bus.audio(s, 1);
n = Buffer.alloc(s, s.sampleRate * 2);

// Bus for SideChain
k = Bus.audio(s, 1); // channels for the kick
g = NetAddr("localhost", 57140);

//SynthDefs

SynthDef(\GrainBuff, {| gate = 0, rate = 1, pos = 0.3, ffreq = 5000, rq = 0.9, releaseTime = 0.1, amp = 0.5 |

	var env1 = EnvGen.ar(Env.asr(0.5, 1, 1),gate, doneAction:0);
	var sndbuf = b;
	var kick = In.ar(k, 2);
	var snd = GrainBuf.ar(1, Dust.ar(300), 0.2,n , rate, pos) ;
    var env = EnvGen.ar(Env.adsr(0.01,0.1,0.9, releaseTime), doneAction: 2);
	snd = CombC.ar(snd, 0.3, 0.2, add: snd * 0.7);
	snd = Compander.ar(snd, kick, 0.1, 1, 0.1, 0.1, 0.1);
	snd = RLPF.ar(snd, ffreq, rq);

	Out.ar(0, (snd.dup * env * amp)* env1);

}).add;

SynthDef(\kickDrum, { |amp = 1|

	var in = Impulse.ar(0.5);
	var snd = Decay2.ar(in, 0.01, 1)  * SinOsc.ar(60).dup ;
	var snd2;
	var env = EnvGen.kr(Env.perc(0.01,2));
	var env2 = (EnvGen.kr(Env.adsr(0.01,0.1, 0.5, 0.5, 1)));


	snd = LPF.ar(snd ,220);


	Out.ar(k, snd * env * amp * 8);
	//Out.ar(0, snd * env * amp) * env;

}).add;



SynthDef(\gong, {|gate = 0, freqscale = 1, freqoffset = 0, decayscale = 1,attack = 0.01,decayTime = 1 sustain = 0.05, release = 5,lfreq = 10, mul = 1 bpf = 400, rq = 1, pan = 0, freq, amp, decay|
	var freqs = Array.fill(8, {20 + 1000.0.rand}) * freqscale;
	var amps =  Array.fill(8, 1);
	var rings = Array.fill(8, {4 + 1.0.rand}) * decayscale;
	var env = EnvGen.ar(Env.adsr(attack, decayTime, sustain, release), gate, doneAction:0);
	//var env = EnvGen.ar(Env.perc(attsck, release, 1),gate,doneAction:2);
	var lfo = SinOsc.ar(lfreq, 0.0, 1);
	var exciter = PinkNoise.ar(0.001 + 0.01.rand);
	var klank = DynKlank.ar(`[freqs, amps, rings], exciter, freqscale, freqoffset, decayscale) * env;
	klank = BPF.ar(klank, bpf, rq) * lfo;
	Out.ar(0, Pan2.ar(Mix.ar(klank), pan));
	Out.ar(~bufbus, Mix.ar(klank));
}).add;


//Record into buf
SynthDef(\recBuf, {|bus = 0, run = 0|
	var sig = In.ar(~bufbus);
	var buf = RecordBuf.ar(sig, n, run:run, loop:1);
	Out.ar(0, sig);
}).add;
)