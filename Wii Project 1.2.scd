//Resonanz Filter Sound
(
~bufbus = Bus.audio(s, 1);
n = Buffer.alloc(s, s.sampleRate* 2);

// Bus for SideChain
k = Bus.audio(s, 1); // channels for the kick

//SynthDefs
SynthDef(\GrainBuff, { |rate = 1, pos = 0.3, ffreq = 5000, rq = 0.9, releaseTime = 0.1, amp = 0.5 |

	var sndbuf = b;
	var kick = In.ar(k, 2);
	var snd = GrainBuf.ar(1, Dust.ar(300), 0.2, sndbuf, rate, pos) ;
    var env = EnvGen.ar(Env.adsr(0.01,0.1,0.9, releaseTime), doneAction: 2);
	snd = CombC.ar(snd, 0.3, 0.2, add: snd * 0.7);
	snd = Compander.ar(snd, kick, 0.1, 1, 0.1, 0.1, 0.1);
	snd = RLPF.ar(snd, ffreq, rq);

	Out.ar(0, snd.dup * env * amp) ;

}).add;

SynthDef(\kickDrum, { |amp = 1|

	var in = Impulse.ar(0.5);
	var snd = Decay2.ar(in, 0.01, 1)  * SinOsc.ar(60).dup ;
	var snd2;
	var env = EnvGen.kr(Env.perc(0.01,2));
	var env2 = (EnvGen.kr(Env.adsr(0.01,0.1, 0.5, 0.5, 1)));


	snd = LPF.ar(snd ,220);


	Out.ar(k, snd * env * amp * 8);
	Out.ar(0, snd * env * amp);

}).add;



SynthDef(\gong, {|gate = 0, freqscale = 1, freqoffset = 0, decayscale = 1,attack = 0.01, sustain = 1, release = 5,lfreq = 10, mul = 1 bpf = 400, rq = 1, pan = 0, freq, amp, decay|
	var freqs = Array.fill(8, {20 + 1000.0.rand}) * freqscale;
	var amps =  Array.fill(8, 1);
	var rings = Array.fill(8, {4 + 1.0.rand}) * decayscale;
	var env = EnvGen.ar(Env.adsr(0.01, 1,0.1, release), gate, doneAction:0);
	//var env = EnvGen.ar(Env.perc(attsck, release, 1),gate,doneAction:2);
	var lfo = SinOsc.ar(lfreq, 0.0, 1);
	var exciter = PinkNoise.ar(0.001 + 0.01.rand);
	var klank = DynKlank.ar(`[freqs, amps, rings], exciter, freqscale, freqoffset, decayscale) * env;
	klank = BPF.ar(klank, bpf, rq) * lfo;
	Out.ar(0, Pan2.ar(Mix.ar(klank), pan));
	Out.ar(~bufbus, Pan2.ar(klank, pan));
}).add;


//Record into buf
SynthDef(\recBuf, {|bus = 0, run = 0|
	var sig = In.ar(~bufbus);
	var buf = RecordBuf.ar(sig, n, run:run, loop:1);
	Out.ar(0, sig);
}).add;

//B gedrückt halten, dann werden und loslassen um klang zu erzeugen


y = Synth(\recBuf);

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
		y.set(\run, 1);
		x.set(
			\gate, 1,
			\bpf, ~spin.linlin(250, 500, 40, 2000),
			\freqscale, ~updown.linlin(-100, 100, 2, 1),
			\lfreq, ~speed.linlin(250, 500, 0, 10),
			\pan, ~leftright.linlin(-100, 100, 1,-1)
		); ~edit = 0;
	}, {x.set(\gate, 0); y.set(\run,0); ~edit = 1});
}, "/wii/button/b");

v = Synth(\GrainBuff);
a = Pgauss(60, 1, inf).asStream;
//y = Synth(\kickDrum);



OSCdef(\Plus, {|msg, time, addr, recvPort|

	r = Routine { i = 0;
	v.set(\rq, 0.3);

		12.do { arg i;
		b = (b - (330 - ((i**2) * 2)));
		if (b < 50) {
			b = 50;
		};
		   v.set(\ffreq, b);
		   b.postln;
		   0.2.wait;
		}
	}.play;

v.set(\rq, 0.9);

}
, "/wii/button/plus");

OSCdef(\Minus, {|msg, time, addr, recvPort|

	r = Routine {
	i = 0;
	v.set(\rq, 0.3);
		12.do { arg i;
		b = (b + ( ((i**2) * 7)));
		if (b > 3000) {
			b = 3000;
		};
		   v.set(\ffreq, b);
		   b.postln;
		   0.2.wait;
		}

	}.play;

v.set(\rq, 0.9);

}
, "/wii/button/minus");


OSCdef(\PosRate, {|msg, time, addr, recvPort|

	v.set(\pos, msg[1].linlin(10, 100, 0.1, 1).round(0.1).postln);
	v.set(\rate, msg[2].linexp(10, 100, 0.7, 1.2).round(0.001));

}, "/wii/orientation");


OSCdef(\SideKick, {|msg|

	Synth(\kickDrum, [
		\amp, msg[1],
		\freq, a.next.round(0.1).postln;
	])

},"/wii/button/b");

)



