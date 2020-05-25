// CroneEngine_GTR
// Guitar kind of thing

Engine_gtr : CroneEngine {
	  var pg;
    var amp = 0.3;
    var pan = 0;
    var bdy,sg,fxg;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		pg = ParGroup.tail(context.xg);
		

    bdy = Bus.audio(context.server , 2);
    sg = Group.tail(context.server);
    fxg = Group.tail(context.server);



    SynthDef(\gtrthing, {
          arg  bus , freq=440, amp=0.5, c3=20, pan=0;
          var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
          var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,1);
          var son = DWGPlucked.ar(freq, amp, 1,0.1,1,c3,inp);
    	  var mx = (son  ) * 0.02;
          DetectSilence.ar(son , 0.001, doneAction:2);
    	  Out.ar(bus, Pan2.ar( mx, pan));
        }).add;

      SynthDef(\body, { | bus |
      	var sig = In.ar(bus,2) ;
      	var reson = Klank.ar(`[[92.5, 180], nil, [0.8, 0.5]],  sig );
      
      	Out.ar(0,  reson * 2 + sig  );
      }).add;
      
      Synth.tail(~fxg,\body,[\bus,~bdy]);

		this.addCommand("note", "ff", { arg msg;
			var ptch = msg[1];
			var amp = msg[2];
      Synth.tail(sg,\gtrthing, [\out,context.out_b,\freq,ptch,\amp,amp,\pan,pan], target:pg);
		});

		this.addCommand("amp", "f", { arg msg;
			amp = msg[1];
		});

		this.addCommand("pan", "f", { arg msg;
		  postln("pan: " ++ msg[1]);
			pan = msg[1];
		});
		
	}
}
