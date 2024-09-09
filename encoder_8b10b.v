
module Encoder_8b10b (
	input  wire clk,
	input  wire reset,
	input  wire ena,
	input  wire KI,
	input  wire [7:0] datain,
	output wire [9:0] dataout
);

    wire aeqb;     // (ai & bi) | (!ai & !bi) ;
    wire ceqd;     // (ci & di) | (!ci & !di) ;
    wire l22;      // (ai & bi & !ci & !di) |
    wire l40;      // ai & bi & ci & di ;
    wire l04;      // !ai & !bi & !ci & !di ;
    wire l13;      // ( !aeqb & !ci & !di) |
    wire l31;      // ( !aeqb & ci & di) |
    wire pd1s6;    // (ei & di & !ci & !bi & !ai) | (!ei & !l22 & !l31) ;
    wire nd1s6;    // ki | (ei & !l22 & !l13) | (!ei & !di & ci & bi & ai) ;
    wire ndos6;    // pd1s6 ;
    wire pdos6;    // ki | (ei & !l22 & !l13) ;
    wire nd1s4;    // fi & gi ;
    wire pd1s4;    // (!fi & !gi) | (ki & ((fi & !gi) | (!fi & gi))) ;
    wire ndos4;    // (!fi & !gi) ;
    wire pdos4;    // fi & gi & hi ;
    wire illegalk; // ki & 
    wire compls6;  // (pd1s6 & !dispin) | (nd1s6 & dispin) ;
    wire disp6;    // dispin ^ (ndos6 | pdos6) ;
    wire compls4;  // (pd1s4 & !disp6) | (nd1s4 & disp6) ;
    wire ai;
    wire bi;
    wire ci;
    wire di;
    wire ei;
    wire fi;
    wire gi;
    wire hi;
    wire ao;
    wire bo;
    wire co;
    wire do;
    wire eo;
    wire io;
    wire fo;
    wire go;
    wire ho;
    wire jo;
    wire dispout;
	
    reg       alt7;     // fi & gi & hi & (ki | 
    reg       dispin;
    reg       dispval;
	reg [9:0] r_data;
	
	assign dataout = r_data;
	
    assign ai = datain[0];
    assign bi = datain[1];
    assign ci = datain[2];
    assign di = datain[3];
    assign ei = datain[4];
    assign fi = datain[5];
    assign gi = datain[6];
    assign hi = datain[7];
	
	always @(posedge clk, negedge reset) begin
		if (~reset) begin
			dispin = 1'b0;
			r_data = 10'b0;
		end else begin
			if (ena == 1'b1) begin
				dispin    = dispout;
				r_data[9] = (ao ^ compls6);
				r_data[8] = (bo ^ compls6);
                r_data[7] = (co ^ compls6);
				r_data[6] = (do ^ compls6);
                r_data[5] = (eo ^ compls6);
				r_data[4] = (io ^ compls6);
                r_data[3] = (fo ^ compls4);
				r_data[2] = (go ^ compls4);
                r_data[1] = (ho ^ compls4);
				r_data[0] = (jo ^ compls4);
			end
		end
	end
	
    assign aeqb = (ai && bi) || (~ai && ~bi) ;
    assign ceqd = (ci && di) || (~ci && ~di) ;
    assign l22  = (ai && bi && ~ci && ~di) || 
                  (ci && di && ~ai && ~bi) || 
                  (~aeqb && ~ceqd);
    assign l40 = ai && bi && ci && di;
    assign l04 = ~ai && ~bi && ~ci && ~di ;
    assign l13 = (~aeqb && ~ci && ~di) || 
                 (~ceqd && ~ai && ~bi);
    assign l31 = (~aeqb && ci && di) ||
                 (~ceqd && ai && bi);

    // The 5B/6B encoding
    assign ao = ai;
    assign bo = (bi && ~l40) || l04;
    assign co = l04 || ci || (ei && di && ~ci && ~bi && ~ai);
    assign do = di && (~(ai && bi && ci));
    assign eo = (ei || l13) && ~(ei && di && ~ci && ~bi && ~ai) ;
    assign io = (l22 && ei) || 
                (ei && ~di && ~ci && ~(ai && bi)) || // D16, D17, D18
                (ei && l40) || 
                (KI && ei && di && ci && ~bi && ~ai) || // K.28
                (ei && ~di && ci && ~bi && ~ai);

    // pds16 indicates cases where d-1 is assumed + to get our encoded value
    assign pd1s6 = (ei && di && ~ci && ~bi && ~ai) || (~ei && ~l22 && ~l31);
    // nds16 indicates cases where d-1 is assumed - to get our encoded value
    assign nd1s6 = KI || (ei && ~l22 && ~l13) || (~ei && ~di && ci && bi && ai);

    // ndos6 is pds16 cases where d-1 is + yields - disp out - all of them
    assign ndos6 = pd1s6;
    // pdos6 is nds16 cases where d-1 is - yields + disp out - all but one
    assign pdos6 = KI || (ei && ~l22 && ~l13) ;

    // some Dx.7 and all Kx.7 cases result in run length of 5 case unless
    // an alternate coding is used (referred to as Dx.A7, n||mal is Dx.P7)
    // specifically, D11, D13, D14, D17, D18, D19.	
	always @(fi, gi, hi, KI, ei, dispin, di, l31, l13) begin
		if (dispin == 1'b1) begin
			dispval = (~ei && di && l31);
		end
		else begin
			dispval = (ei && ~di && l13);
		end
		
		alt7 = fi && gi && hi && (KI || dispval);
	end
	
	assign fo = fi && ~alt7;
    assign go = gi || (~fi && ~gi && ~hi);
    assign ho = hi;
    assign jo = (~hi && (gi ^ fi)) || alt7;

    // nd1s4 is cases where d-1 is assumed - to get our encoded value
    assign nd1s4 = fi && gi;
    // pd1s4 is cases where d-1 is assumed + to get our encoded value
    assign pd1s4 = (~fi && ~gi) || (KI && ((fi && ~gi) || (~fi && gi))) ;

    // ndos4 is pd1s4 cases where d-1 is + yields - disp out - just some
    assign ndos4 = (~fi && ~gi);
    // pdos4 is nd1s4 cases where d-1 is - yields + disp out 
    assign pdos4 = fi && gi && hi;

    // only legal K codes are K28.0->.7, K23/27/29/30.7
    //    K28.0->7 is ei=di=ci=1,bi=ai=0
    //    K23 is 10111
    //    K27 is 11011
    //    K29 is 11101
    //    K30 is 11110 - so K23/27/29/30 are ei  and  l31
    //illegalk = KI  and
          //(ai  ||  bi  ||  ~ci  ||  ~di  ||  ~ei)  and  // ~K28.0->7
          //(~fi  ||  ~gi  ||  ~hi  ||  ~ei  ||  ~l31) ; // ~K23/27/29/30.7

    // now determine whether to do the complementing
    // complement if prev disp is - and pd1s6 is set, || + and nd1s6 is set
    assign compls6 = (pd1s6 && (~dispin)) || (nd1s6 && dispin);

    // disparity out of 5b6b is disp in with pdso6 and ndso6
    // pds16 indicates cases where d-1 is assumed + to get our encoded value
    // ndos6 is cases where d-1 is + yields - disp out
    // nds16 indicates cases where d-1 is assumed - to get our encoded value
    // pdos6 is cases where d-1 is - yields + disp out
    // disp toggles in all ndis16 cases, and all but that 1 nds16 case
    assign disp6 = dispin ^ (ndos6 || pdos6);
    assign compls4 = (pd1s4 && ~disp6) || (nd1s4 && disp6);
    assign dispout = disp6 ^ (ndos4 || pdos4) ;

endmodule
