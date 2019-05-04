//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2019 


module	adj_size_square_object	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic	[10:0] topLeftX, //position on the screen 
					input 	logic	[10:0] topLeftY,
					input	logic	[2:0]  size_shift, //set the size in *2 steps (signed integer)
					
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic   [2:0]  size_Shift_out,
					output	logic	[7:0]	 RGBout //optional color output for mux 
);
parameter  int OBJECT_WIDTH_X = 32;
parameter  int OBJECT_HEIGHT_Y = 32;
parameter  logic [7:0] OBJECT_COLOR = 8'h5b ; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
 
int rightX ; //coordinates of the sides  
int bottomY ;
logic insideBracket ; 

// Calculate object right  & bottom  boundaries
always_comb begin

	if (size_shift > 0) begin
		rightX	= (topLeftX + OBJECT_WIDTH_X << size_shift);
		bottomY	= (topLeftY + OBJECT_HEIGHT_Y << size_shift);
	end else if (size_shift == 0) begin
		rightX	= (topLeftX + OBJECT_WIDTH_X);
		bottomY	= (topLeftY + OBJECT_HEIGHT_Y);
	end else begin
		rightX	= (topLeftX + OBJECT_WIDTH_X >> size_shift);
		bottomY	= (topLeftY + OBJECT_HEIGHT_Y >> size_shift);
	end
end

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else begin 
	

		//this is an example of using blocking sentence inside an always_ff block, 
		//and not waiting a clock to use the result  
		insideBracket  = 	 ( (pixelX  >= topLeftX) &&  (pixelX < rightX) // ----- LEGAL BLOCKING ASSINGMENT in ALWAYS_FF CODE 
						   && (pixelY  >= topLeftY) &&  (pixelY < bottomY) )  ; 
		
		if (insideBracket ) // test if it is inside the rectangle 
		begin 
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - topLeftX); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - topLeftY);
		end 
		
		else begin  
			RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
			drawingRequest <= 1'b0 ;// transparent color 
			offsetX	<= 0; //no offset
			offsetY	<= 0; //no offset
		end 
		
	end
end 

assign size_Shift_out = size_shift;
endmodule 
