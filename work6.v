`timescale 1ns / 1ps
module work6(clk,rst,dinout,led,button1);

    input clk,rst,button1;
    output [7:0] led;
    inout dinout;
    wire b1;
    
    button bt1(b1,button1,clk,rst);
    data data1(clk,rst,dinout,led,b1);
endmodule

module data(clk,rst,dinout,led,button1);  
    input clk,rst,button1;
    output reg [7:0] led;
    inout dinout;
    
    wire din,dout;
    reg en=0;
    assign dout = 0 ;
    
    assign dinout = button1 ? dout : 1'bz;
    assign din    = button1 ? 1'b1 : dinout;
    
    always@(posedge clk or negedge rst)
        begin
            if(rst)
                begin
                    led<=8'b0000_0000;
                end
            else
                begin
                    if(din==0)
                        led<=8'b1;
                    else
                        led<=8'b0;
                end
         end
endmodule

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