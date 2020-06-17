//Player 3
(
~player = 2;
~id = 0;
y = Synth(\recBuf);
v = Synth(\GrainBuff);
a = Pgauss(60, 1, inf).asStream;
x = Synth(\gong);



OSCdef(\accj, {|msg|

	g.sendMsg("/wii/acc/" ++ ~id.asString,  msg[1], msg[2], msg[3])
}, "/wii/acc");


OSCdef(\orj, {|msg|

	g.sendMsg("/wii/orientation/" ++ ~id.asString,  msg[1], msg[2])
}, "/wii/orientation");


OSCdef(\aj, {|msg|

	g.sendMsg("/wii/button/a/" ++ ~id.asString,  msg[1])
}, "/wii/button/a");

OSCdef(\bj, {|msg|
	g.sendMsg("/wii/button/b/" ++ ~id.asString,  msg[1])
}, "/wii/button/b");


OSCdef(\minj, {|msg|

	g.sendMsg("/wii/acc/"++ ~id.asString,  msg[1])
}, "/wii/button/minus");


OSCdef(\plusj, {|msg|
	g.sendMsg("/wii/acc/"++ ~id.asString,  msg[1])
}, "/wii/button/plus");


OSCdef(\runj, {|msg|
	~run = msg[1];
	y.set(\run, ~run);
}, "/run");

OSCdef(\idj, {|msg|
	["ID", ~id].postln;
	~id = msg[1];
}, "/id/2");

OSCdef(\switch, {|msg|

	~id.postln;
	if((msg[1] == 0), {
		~id = 0;
		g.sendMsg("/id/" ++ [,1,3].choose.asString, 1);
	});
}, "/wii/button/b");


//Resonanz Filter Sound


//B gedrückt halten, dann werden und loslassen um klang zu erzeugen


OSCdef(\acc, {|msg|
	~speed = msg[1];
	~spin =  msg[2];
}, "/wii/acc/1");

OSCdef(\orientation, {|msg|
	~leftright = msg[1];
	~updown = msg[2];
}, "/wii/orientation/1");

OSCdef(\ButtonB, {|msg|
	msg.postln;

	~edit = 0;
	~gate = msg[1];
	//~gate.postln;
	if(~gate == 0, {


		"lel".postln;
		~run = 1;
		v.set(\gate, 0);
		y.set(\run, ~run);
		g.sendMsg("/run", ~run);
		x.set(
			\gate, 1,
			\bpf, ~spin.linlin(250, 500, 40, 2000),
			\freqscale, ~updown.linlin(-100, 100, 2, 1),
			\lfreq, ~speed.linlin(250, 500, 0, 10),
			\pan, ~leftright.linlin(-100, 100, 0.8,-0.8)
		); ~edit = 0;
	}, {~run = 0; g.sendMsg("/run", ~run); x.set(\gate, 0); v.set(\gate, 1); y.set(\run,0); ~edit = 1;~id = 1});
}, "/wii/button/b/1");


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
		   //b.postln;
		   0.2.wait;
		}
	}.play;

v.set(\rq, 0.9);

}
, "/wii/button/plus/1");

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
		   //b.postln;
		   0.2.wait;
		}

	}.play;

v.set(\rq, 0.9);

}
, "/wii/button/minus/1");


OSCdef(\PosRate, {|msg, time, addr, recvPort|

	v.set(\pos, msg[1].linlin(10, 100, 0.1, 1).round(0.1));
	v.set(\rate, msg[2].linexp(10, 100, 0.7, 1.2).round(0.001));

}, "/wii/orientation/1");


OSCdef(\SideKick, {|msg|

	Synth(\kickDrum, [
		\amp, msg[1],
		\freq, a.next.round(0.1);
	])

},"/wii/button/a/1");
);

