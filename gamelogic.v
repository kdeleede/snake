`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:51 03/02/2022 
// Design Name: 
// Module Name:    gamelogic 
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
module gamelogic(
    input master_clk,
	 input game_speed_clk,
	 input [1:0] direction,
	 input [9:0] index,
	 input rst,
	 output reg [9:0] score,
	 output reg won,
	 output reg lost,
	 output is_snake,
	 output is_food
	 );
	 
parameter BACKGROUND = 8'b00000000;
parameter SNAKE_COLOR = 8'b00011000;
parameter FOOD_COLOR = 8'b00010011;
parameter MAX = 30;
parameter WIN = 18;

reg [29:0] check_snake;
reg [9:0] snake_body [29:0];
reg [9:0] head;
reg [9:0] length;
reg [9:0] food;
reg [9:0] random_num_1;

/*
always @(master_clk)
begin
	random_num_1 <= (random_num_1 + 1) % 900;
end
*/

reg [9:0] next_head;

integer i;
initial begin
	for (i=0; i<30; i=i+1) begin
		snake_body[i] = 10'd1000;
	end
	food <= 88;
	snake_body[0] = 10'd3;
	snake_body[1] = 10'd2;
	snake_body[2] = 10'd1;
	snake_body[3] = 10'd0;
	
	length <= 9'd4;
	won <= 0;
	lost <= 0;
	score <= 0;
end

assign is_food = (food == index);

always @(posedge master_clk)
begin
	for (i=0; i<30; i=i+1) begin
		check_snake[i] <= (index == snake_body[i]);
	end
end

assign is_snake = |check_snake;

assign game_over = (|check_snake[29:1] & check_snake[0]);

//   2
// 0   1
//   3

reg lose;

always @(posedge game_speed_clk) begin
	case(direction)
		2'd0:
		begin
			if ((snake_body[0] % 30) == 0)
				next_head <= snake_body[0] + 10'd29;
			else
				next_head <= snake_body[0] - 10'd1;
		end
		2'd1:
		begin
			if ((snake_body[0] % 30) == 29)
				next_head <= snake_body[0] - 10'd29;
			else
				next_head <= snake_body[0] + 10'd1;
		end
		2'd2:
		begin
			if ((snake_body[0] / 30) == 0)
				next_head <= snake_body[0] + 10'd870;
			else
				next_head <= snake_body[0] - 10'd30;
		end
		2'd3:
		begin
			if ((snake_body[0] / 30) == 29)
				next_head <= snake_body[0] - 10'd870;
			else
				next_head <= snake_body[0] + 10'd30;
		end
		endcase
end	  



reg [9:0] snake_transition [29:0];

always @(posedge master_clk) begin

	if (rst) begin
		for (i=0; i<30; i=i+1) begin
			snake_body[i] = 10'd1020;
		end
		food <= (food+3) * 1023 %900;
		snake_body[0] = 10'd3;
		snake_body[1] = 10'd2;
		snake_body[2] = 10'd1;
		snake_body[3] = 10'd0;
		
		length <= 9'd4;
		//random_num =0;
		won <= 0;
		lost <= 0;
		score <= 0;
	end
	if (game_over & ~rst) begin
		lost <= 1;
	end
	if (game_speed_clk & ~lost) begin
	
		if ((direction == 2'd0 && (snake_body[0] % 30) == 0) || (direction == 2'd1 && (snake_body[0] % 30) == 29) || (direction == 2'd2 && (snake_body[0] / 30) == 0) || (direction == 2'd3 && (snake_body[0] / 30) == 29)) begin
			lost <= 1;
		end
			else begin
			for (i=29; i!=0; i=i-1) begin
				if (i<length)
					snake_body[i] = snake_transition[i];
			end
			snake_body[0] = next_head;
		end
	end
	if (~game_speed_clk & next_head != food & ~lost) begin
		for (i=29; i!=0; i=i-1) begin
			if (i<length)
				snake_transition[i] = snake_body[i-1];
		end
	end
	if (~game_speed_clk & next_head == food &~lost) begin
		length <= length + 1;
		score <= score + 1;
		food <= food * 1023 %900;//food * 1023 %900;
		for (i=29; i!=0; i=i-1) begin
			if (i<length)
				snake_transition[i] = snake_body[i-1];
		end
	end
end



endmodule
