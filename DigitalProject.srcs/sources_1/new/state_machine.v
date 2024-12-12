`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/30 16:00:07
// Design Name: 
// Module Name: state_machine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module state_machine(
    input clk,
    input clk_de,
    input reset,
    input power,
    input menu,
    input state_01,
    input state_02,
    input state_03,
    input state_clean_auto,
    input state_clean_manual, 
    output display_menu,
    output display_01,
    output display_02,
    output display_03,
    output display_clean,  
    output [17:0] work_time,
    output reg [5:0] work_count_down,
    output reg cleaned,
    output reg [2:0] State
);

 
    parameter on = 1'b1, off = 1'b0;
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100,S5= 3'b101,S6= 3'b110, S7=3'b111;  
    parameter wait_period_S3 = 1000;  
    parameter wait_period_clean = 3000; 
    
   
    reg [15:0] time_count_S3;
    reg [15:0] time_count_clean;
    reg [5:0] sec;
    reg [5:0] min;
    reg [5:0] hour;
    reg [4:0] display;
    reg in_menu_mode;  
    reg entered_S3,next_entered_S3;   
    reg next_cleaned;
    reg [31:0] count=0,next_count=0;
    reg [15:0] next_time_count_S3;
    reg [15:0] next_time_count_clean;
    reg [2:0] next_state;
    reg next_in_menu_mode;    
 
    reg state_01_stable, state_02_stable, state_03_stable, state_clean_stable;
    reg [3:0] state_01_counter, state_02_counter, state_03_counter, state_clean_counter;
    parameter DEBOUNCE_THRESHOLD = 4'b0001;  
    parameter divider = 100;

    assign display_menu = display[0];
    assign display_01 = display[1];
    assign display_02 = display[2];
    assign display_03 = display[3];
    assign display_clean = display[4];
    
    assign work_time={hour,min,sec};


    //   ??    
    always @(posedge clk_de or negedge reset) begin
        if (~reset) begin
            state_01_stable <= 0;
            state_02_stable <= 0;
            state_03_stable <= 0;
            state_clean_stable <= 0;
            state_01_counter <= 0;
            state_02_counter <= 0;
            state_03_counter <= 0;
            state_clean_counter <= 0;
        end else begin
            //   ?    ?         ?        
            if (state_01) begin
                if (state_01_counter < DEBOUNCE_THRESHOLD) begin
                    state_01_counter <= state_01_counter + 1;
                end else begin
                    state_01_stable <= 1;
                end
            end else begin
                state_01_counter <= 0;
                state_01_stable <= 0;
            end

            if (state_02) begin
                if (state_02_counter < DEBOUNCE_THRESHOLD) begin
                    state_02_counter <= state_02_counter + 1;
                end else begin
                    state_02_stable <= 1;
                end
            end else begin
                state_02_counter <= 0;
                state_02_stable <= 0;
            end

            if (state_03) begin
                if (state_03_counter < DEBOUNCE_THRESHOLD) begin
                    state_03_counter <= state_03_counter + 1;
                end else begin
                    state_03_stable <= 1;
                end
            end else begin
                state_03_counter <= 0;
                state_03_stable <= 0;
            end

            if (state_clean_auto) begin
                if (state_clean_counter < DEBOUNCE_THRESHOLD) begin
                    state_clean_counter <= state_clean_counter + 1;
                end else begin
                    state_clean_stable <= 1;
                end
            end else begin
                state_clean_counter <= 0;
                state_clean_stable <= 0;
            end
        end
    end

    // ??  ?  
    always @(posedge clk_de) begin
        State<=next_state;
        in_menu_mode<=next_in_menu_mode;
        time_count_S3<=next_time_count_S3;
        time_count_clean<=next_time_count_clean;
        entered_S3<=next_entered_S3;
        cleaned<=next_cleaned;
        if (state_clean_manual) begin
            count<=0;
            sec<=0;
            min<=0;
            hour<=0;  
        end else begin
            count<=next_count;
            sec<=next_count/100%60;
            min<=next_count/6000%60;
            hour<=next_count/360000%24;     
        end   
    end
    
    always @(*) begin
	    case (State) 
	    	S5: begin
	    		display=5'b00000;
	    		next_in_menu_mode=0;
	    		next_time_count_S3 = 0;
				next_time_count_clean = 0;
				next_entered_S3=0;
				next_cleaned = 0;
	    		if (power) next_state=S0;
	    		else next_state=S5;
	    		next_count=0;
			end
			
			S0: begin
	    		display=5'b00001;
	    		next_time_count_S3 = 0;
				next_time_count_clean = 0;
                next_entered_S3=entered_S3;
				next_cleaned = off;
				next_count=count;
	    		if (!power) begin
                    next_state = S5;
                    next_in_menu_mode=0;
                end else if (!menu&in_menu_mode) begin 
					next_state=S6;
					next_in_menu_mode=0;
	    		end else begin
					next_state=S0;
					if (menu) next_in_menu_mode=1;
					else next_in_menu_mode=in_menu_mode;
				end
			end
			
			S6: begin
	    		display=5'b00001;
	    		next_in_menu_mode=0;
	    		next_time_count_S3 = 0;
				next_time_count_clean = 0;
                next_entered_S3=entered_S3;
                next_cleaned = 0;
                next_count=count;
	    		if (!power) begin
                    next_state = S5;
                end else if (state_01_stable) begin
                    next_state = S1;
                end else if (state_02_stable) begin
                    next_state = S2;
                end else if (state_03_stable && !entered_S3) begin
                    next_state = S3;
                end else if (state_clean_stable) begin
                    next_state = S4;
                end else begin
                    next_state = S6;
                end
			end
			
	    	S1: begin
	    		display=5'b00010;
	    		next_time_count_S3 = 0;
				next_time_count_clean = 0;
                next_entered_S3=entered_S3;
                next_cleaned = 0;
                next_count=count+1;
                if (!power) begin
                    next_state = S5;
                    next_in_menu_mode=0;
                end else if (!menu&state_02_stable) begin
                    next_state = S2;
                    next_in_menu_mode = 0;
                end else begin
                    if (in_menu_mode&!menu) begin
                        next_state = S0;
                        next_in_menu_mode = 0;
                    end else begin
                        next_state = S1;
                        if (menu) next_in_menu_mode=1;
						else next_in_menu_mode=in_menu_mode;
                    end
                end
			end
			
			S2: begin
	    		display=5'b00100;
	    		next_time_count_S3 = 0;
				next_time_count_clean = 0;
                next_entered_S3=entered_S3;
                next_cleaned = 0;
                next_count=count+1;
	    		if (!power) begin
                    next_state = S5;
                    next_in_menu_mode=0;
                end else if (!menu&state_01_stable) begin
                    next_state = S1;
                    next_in_menu_mode = 0;
                end else begin
                    if (in_menu_mode&!menu) begin
                        next_state = S0;
                        next_in_menu_mode = 0;
                    end else begin
                        next_state = S2;
                        if (menu) next_in_menu_mode=1;
						else next_in_menu_mode=in_menu_mode;
                    end
                end
			end
			
			S3: begin
	    		display=5'b01000;
	    		next_time_count_clean = 0;
	    		next_entered_S3 = 1;  
                next_cleaned = 0;
	    		work_count_down = (wait_period_S3 - time_count_S3) / divider + 1;
	    		next_count=count+1;
	    		if (!power) begin
                    next_state = S5;
                    next_in_menu_mode=0;
                end else begin
                    next_time_count_S3 = time_count_S3 + 1;
                    if (in_menu_mode&!menu) begin
                        next_time_count_S3 = 0;
                        next_state = S7;
                        next_in_menu_mode = 0;
                    end else begin
                        if (time_count_S3 > wait_period_S3) begin
                            next_state = S2;
                            next_in_menu_mode= 0;
                        end else begin
                            next_time_count_S3 = time_count_S3 + 1;
                            next_state = S3;
                            if (menu) next_in_menu_mode=1;
							else next_in_menu_mode=in_menu_mode;
                        end
                    end
				end
			end
			
			S7: begin
			display=5'b01000;
                next_time_count_clean = 0;
                next_entered_S3 = 1;  
                next_cleaned = 0;
                work_count_down = (wait_period_S3 - time_count_S3) / divider + 1;
                next_count=count+1;
                if (!power) begin
                    next_state = S5;
                    next_in_menu_mode=0;
                end else begin
                    if (time_count_S3 > wait_period_S3) begin
                        next_state = S0;
                        next_in_menu_mode = 0;
                    end else begin
                        next_time_count_S3 = time_count_S3 + 1;
                        next_in_menu_mode = in_menu_mode;
                        next_state = S7;
                    end
                end
            end
			     
				
			S4: begin
	    		display=5'b10000;
	    		next_time_count_S3 = 0;
                next_entered_S3=entered_S3;
				next_in_menu_mode=0;
                work_count_down = (wait_period_clean - time_count_clean) / divider + 1;
                if (!power) begin
                    next_state = S5;
                    next_cleaned=0;
                    next_count=0;
                end else begin
                	next_time_count_clean = time_count_clean + 1;
                    if (time_count_clean > wait_period_clean) begin
                        next_count=0;
                        next_state = S0;
                    end else begin
                        next_state = S4;
                        next_count=count;
                    end
				end
			end
			default: begin
			    next_state=S5;
			    next_time_count_clean=0;
			    next_time_count_S3=0;
			    next_in_menu_mode=0;
                next_entered_S3=0;
                next_cleaned=0;
                next_count=0;
			end
	    endcase
	end
    
//    //  ? ??   ?  
//    always @(posedge clk_de or negedge reset) begin
//        if (~reset) begin
//                count <= 0;
//                sec <= 0;
//                min <= 0;
//                hour <= 0;
//        end else if (power)begin
//            if(State == S1|State == S2|State == S3|State == S7) begin
//                if(count == 100) begin
//                    count <= 0;
//                    if (sec == 59) begin
//                        sec <= 0;
//                        if (min == 59) begin
//                            min <= 0;
//                            if (hour == 23) begin
//                                hour <= 0;
//                            end else begin
//                                hour <= hour + 1;
//                            end
//                        end else begin
//                            min <= min + 1;
//                        end
//                    end else begin
//                        sec <= sec + 1;
//                    end
//                end else begin
//                    count <= count + 1;
//                end
//            end else if (cleaned|state_clean_manual)begin
//                    sec <= 0;
//                    min <= 0;
//                    hour <= 0;
//                    count <= 0;
//            end else begin

//            end
//        end else begin
//            count <= 0;
//            sec <= 0;
//            min <= 0;
//            hour <= 0;
//        end
//    end
endmodule
