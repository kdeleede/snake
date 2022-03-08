`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:11:49 02/14/2022 
// Design Name: 
// Module Name:    display 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module display(
    input [3:0] number,
	 output reg [6:0] seg
	 );
	 
	 // converting a number (1 digit) to seven digit display
	 // in the seven digit display a 1 corresponds to off
	 
	 always @* begin
		case(number)
			0: seg = 7'b1000000;
			1: seg = 7'b1111001;
			2: seg = 7'b0100100;
			3: seg = 7'b0110000;
			4: seg = 7'b0011001;
			5: seg = 7'b0010010;
			6: seg = 7'b0000010;
			7: seg = 7'b1111000;
			8: seg = 7'b0000000;
			9: seg = 7'b0010000;
			default: seg = 7'b1111111; // OFF
		endcase
	 end
	 
	 


endmodule