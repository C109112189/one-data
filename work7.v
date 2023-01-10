`timescale 1ns / 1ps
module work7(clk,rst,led,button0,dinout,sw);

input clk,rst;
input button0,sw;
output [7:0] led;
inout dinout;

wire din;
wire en;
wire b0,b1;
wire divclk_1,divclk_2;
wire [3:0] Rs,Ls;

assign dinout = en ? 1'b0 : 1'bz;
assign din    = b0 ? 1'b1 : dinout;

div div1(divclk_1,divclk_2,clk,rst);
button bt0(b0,button0,clk,rst);
FSM FSM1(divclk_2,rst,b0,led,Mstar,flag,din,en,sw);



endmodule
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
module FSM(clk,rst,button0,led,Mstar,flag,din,en,sw);
	
	input clk,rst;
	input button0,sw;
	input din;
	output reg [7:0] led;
	output reg  en;
	output reg Mstar,flag;
	reg [7:0] porint;
	integer i;
//	output reg [7:0] seg7_out;
	reg[2:0] state;
	integer cnt;
	parameter star=3'd0 , MR=3'd1 , ML=3'd2; 
	
	always@(posedge clk or negedge rst)
		begin
			if(rst)
				begin
					state<=star;
					Mstar<=0;
					flag<=0;
					en=0;
					cnt=0;
					led<=8'b0000_0000;
					porint<=8'b0000_0000;
				end
			else
				begin
					case(state)
						star:
							begin
								if(button0==1)
									begin
										Mstar<=1;
										state<=MR;
										flag<=0;
										led<=8'b1000_0000;
									end
								else if(~din)
								    begin
								        Mstar<=1;
								        state<=ML;
								        flag<=1;
								        led<=8'b0000_0001;
								    end
								else if(sw)
								    begin
								        led<=porint;
								    end
								else
									begin
										Mstar<=0;
										state<=star;
										flag<=0;
										led<=8'b0000_0000;
									end
							end
						MR:
							begin
								if(flag==0 && Mstar==1)
								    begin
								        for(i=0;i<3;i=i+1)
									       led<=led/2;
									end
								if(led==8'b0000_0000 && cnt<5)
								    begin
								        en<=1;
								        cnt<=cnt+1;
								    end
								if(cnt==4)
								    begin
								        en<=0;
								        state<=star;
								        cnt<=0;
								    end
							end
						ML:
							begin
								if(flag==1 && Mstar==1)
								    begin
								        for(i=0;i<=3;i=i+1)
									       led<=led*2;
									end
								if(led==8'b0000_0000 && cnt<5)
								    begin
								        en<=1;
								        cnt<=cnt+1;
								    end
								else if(led==8'b1000_0000 && button0 == 1)
								    begin
								        state<=MR;
								        flag<=0;
								        cnt<=0;
								    end
								else if(led!=8'b1000_0000 && button0 ==1)
								    begin
								        porint<=porint+1;
								        state<=star;
								        cnt<=0;
								        en<=0;
								    end
								if(cnt==4)
								    begin
								        en<=0;
								        state<=star;
								        cnt<=0;
								    end
							end
					endcase				
				end
		end
endmodule
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
module button(click,in,clk,rst);
	output reg click;
	input in,clk,rst;
	reg [23:0]decnt;

	parameter bound = 24'h000f0f;

	always @ (posedge clk or negedge rst)begin
		if(rst)begin
			decnt <= 0;
			click <= 0;
		end
		else begin
			if(in)begin
				if(decnt < bound)begin
					decnt <= decnt + 1;
					click <= 0;
				end
				else begin
					decnt <= decnt;
					click <= 1;
				end
			end
			else begin
				decnt <= 0;
				click <= 0;
			end
		end
	end
endmodule
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
module div(divclk_1,divclk_2,clk,rst);

input clk,rst;
output divclk_1,divclk_2;
reg [35:0]divclkcnt;

assign divclk_1 = divclkcnt[25];
assign divclk_2 = divclkcnt[23];

always@(posedge clk or negedge rst)begin
    if(rst)
        divclkcnt = 0;
    else
        divclkcnt = divclkcnt + 1;
end
endmodule
