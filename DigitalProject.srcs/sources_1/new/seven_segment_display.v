module seven_segment_display (
    input [5:0] sec, min, hour,
    input [3:0] select,
    output reg [7:0] seg1,
    output reg [7:0] seg2,
    output [5:0] an
);

    reg [7:0] seg_map [0:9]; 
    initial begin
        seg_map[0] = 8'b11111100;
        seg_map[1] = 8'b01100000;
        seg_map[2] = 8'b11011010;
        seg_map[3] = 8'b11110010;
        seg_map[4] = 8'b01100110;
        seg_map[5] = 8'b10110110;
        seg_map[6] = 8'b10111110;
        seg_map[7] = 8'b11100000;
        seg_map[8] = 8'b11111110;
        seg_map[9] = 8'b11110110;
    end

    always @(*) begin
        case (select)
            4'd0: seg1 = seg_map[hour / 10];
            4'd1: seg1 = seg_map[hour % 10];
            4'd2: seg1 = seg_map[min / 10];
            4'd3: seg1 = seg_map[min % 10];
            4'd4: seg2 = seg_map[sec / 10];
            4'd5: seg2 = seg_map[sec % 10];
            default: begin seg1 = 8'b00000000; seg2 = 8'b00000000; end
        endcase
    end
endmodule
