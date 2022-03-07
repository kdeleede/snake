`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:14:17 03/04/2022 
// Design Name: 
// Module Name:    main 
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
module main(
	input clk,
	input rst,
	input btnu,
	input btnd,
	input btnl,
	input btnr,
	output reg [7:0] rgb,
	output hsync1,
	output vsync1,
	output reg [9:0] h_counter,
	output reg [9:0] v_counter
    );
	 
	parameter BACKGROUND = 8'b00000000;
	parameter SNAKE_COLOR = 8'b00100011;
	parameter FOOD_COLOR = 8'b00000011;
	parameter WHITE = 8'b11111111;
	parameter MAX = 30;
	parameter WIN = 18;
	 
	initial rgb = BACKGROUND;
	
	//////////////////////////////////////////////////////////
	
	reg half_clk;
	reg dclk;
	initial begin
		half_clk <= 0;
		dclk <= 0;
	end
	
	always @(posedge clk) begin
		half_clk <= ~half_clk;
		if (half_clk) begin
			dclk <= ~dclk;
		end
	end
	
	reg [31:0] count_1hz;
	reg clk_1hz;
	
	initial begin
		count_1hz <= 0;
		clk_1hz <= 0;
	end
	
	always @(posedge clk) begin
		if (count_1hz == 49999999) begin
			count_1hz <= 0;
			clk_1hz <= ~clk_1hz;
		end
		else begin
			count_1hz <= count_1hz + 1;
		end
	end
	
	reg [31:0] count_2hz;
	reg clk_2hz;
	
	initial begin
		count_2hz <= 0;
		clk_2hz <= 0;
	end
	
	always @(posedge clk) begin
		if (count_2hz == 6249999) begin
			count_2hz <= 0;
			clk_2hz <= ~clk_2hz;
		end
		else begin
			count_2hz <= count_2hz + 1;
		end
	end
	
	///////////////////////////////////////////////////////////
	
	wire is_snake;
	wire is_food;
	reg in_display;
	reg is_border;
	
	initial begin
		is_border <= 0;
		in_display <=0;
	end
	
	always @(posedge clk) begin
		if (h_counter > 223 && h_counter < 705 && v_counter > 33 && v_counter <515)
			in_display <= 1;
		else
			in_display <= 0;
	end
	

	reg [9:0] index_reg;
	wire [9:0] index;
	assign index = index_reg;
	
	always @(posedge clk) begin
		index_reg <= (h_counter - 224) / 16 + (v_counter - 35) / 16 * 30;
	end
	
	
	always @(posedge clk) begin
		if ((h_counter - 224) % 16 == 0 | (v_counter - 35) % 16 == 0 | v_counter == 514)
			is_border = 1;
		else
			is_border = 0;
	end
	
	wire won;
	wire lost;
	
	always @(posedge clk) begin
		if (in_display) begin
			if (is_border)
				rgb <= WHITE;
			else if (is_snake)
				rgb <= SNAKE_COLOR;
			else if (is_food)
				rgb <= FOOD_COLOR;
			else
				rgb <= BACKGROUND;
		end
		else
			rgb <= BACKGROUND;
	end
	
	////////////////////////////////////////////
	
	reg [1:0] direction;
	reg [1:0] next_direction;
	
	initial begin
		direction = 2'd1;
		next_direction = 2'd1;
	end
	
	always @(posedge clk) begin
		if (rst) begin
			direction <= 2'd1;
			next_direction <= 2'd1;
		end
		if (clk_2hz)
			direction <= next_direction;
		else if (btnr) begin
			if (direction != 2'd0)
				next_direction <= 2'd1;
		end
		else if (btnl) begin
			if (direction != 2'd1)
				next_direction <= 2'd0;
		end
		else if (btnu) begin
			if (direction != 2'd3)
				next_direction <= 2'd2;
		end
		else if (btnd) begin
			if (direction != 2'd2)
				next_direction <= 2'd3;
		end
	end
	
	wire score;
	
	////////////////////////////////////////////
	
	
	// video structure constants
	parameter hpixels = 800;// horizontal pixels per line
	parameter vlines = 521; // vertical lines per frame
	parameter hpulse = 96; 	// hsync pulse length
	parameter vpulse = 2; 	// vsync pulse length
	parameter hbp = 144; 	// end of horizontal back porch
	parameter hfp = 784; 	// beginning of horizontal front porch
	parameter vbp = 31; 		// end of vertical back porch
	parameter vfp = 511; 	// beginning of vertical front porch
	// active horizontal video is therefore: 784 - 144 = 640
	// active vertical video is therefore: 511 - 31 = 480


	// Horizontal & vertical counters --
	// this is how we keep track of where we are on the screen.
	// ------------------------
	// Sequential "always block", which is a block that is
	// only triggered on signal transitions or "edges".
	// posedge = rising edge  &  negedge = falling edge
	// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
	always @(posedge dclk)
	begin
		begin
			// keep counting until the end of the line
			if (h_counter < hpixels - 1)
				h_counter <= h_counter + 1;
			else
			// When we hit the end of the line, reset the horizontal
			// counter and increment the vertical counter.
			// If vertical counter is at the end of the frame, then
			// reset that one too.
			begin
				h_counter <= 0;
				if (v_counter < vlines - 1)
					v_counter <= v_counter + 1;
				else
					v_counter <= 0;
			end
			
		end
	end

	// generate sync pulses (active low)
	// ----------------
	// "assign" statements are a quick way to
	// give values to variables of type: wire
	assign hsync1 = (h_counter < hpulse) ? 0:1;
	assign vsync1 = (v_counter < vpulse) ? 0:1;
	
	////////////////////////////////////////////////////////////


	
	gamelogic gamelogic(
		.master_clk(clk),
		.game_speed_clk(clk_2hz),
		.direction(direction),
		.index(index),
		.rst(rst),
		.score(score),
		.won(won),
		.lost(lost),
		.is_snake(is_snake),
		.is_food(is_food)
	);
	
	
	

endmodule