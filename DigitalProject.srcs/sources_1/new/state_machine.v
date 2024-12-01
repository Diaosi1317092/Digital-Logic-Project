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
    input reset,
    input power,
    input menu,
    input state_01,
    input state_02,
    input state_03,
    input state_clean, //��ť����
    output display_menu,
    output display_01,
    output display_02,
    output display_03,
    output display_clean, //״̬��LED��ʾ
    output reg cleaned
);

    // ����״̬
    parameter on = 1'b1, off = 1'b0;
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100; //������һ���������������������
    parameter wait_period_S3 = 4'b0110; //�����Զ��л��������ߴ�����ʱ��
    parameter wait_period_clean = 4'b0100; //������ʱ��

    reg [2:0] State;
    reg [3:0] time_count_menu;
    reg [3:0] time_count_S2;
    reg [3:0] time_count_clean;
    reg [4:0] display;
    reg in_menu_mode; // ��������Ƿ��ڲ˵�ģʽ
    reg entered_S3;  // �����źţ�����Ƿ��Ѿ������S3״̬

    // ��ťȥ��������
    reg state_01_stable, state_02_stable, state_03_stable, state_clean_stable;
    reg [3:0] state_01_counter, state_02_counter, state_03_counter, state_clean_counter;
    parameter DEBOUNCE_THRESHOLD = 4'b0001;  //������Ҫ����

    assign display_menu = display[0];
    assign display_01 = display[1];
    assign display_02 = display[2];
    assign display_03 = display[3];
    assign display_clean = display[4];

    // ��ťȥ����
    always @(posedge clk or negedge reset) begin
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
            // ��ÿ����ť���������ȥ��������
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

            if (state_clean) begin
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

    // ״̬��ʵ��
    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            State <= S0;
            display <= 5'b00001;
            cleaned <= off;
            in_menu_mode <= 0; // ��ʼ��Ϊ���ڲ˵�ģʽ
            entered_S3 <= 0;  // ��ʼ�� entered_S3 Ϊ 0
        end else if (power) begin
            case (State)
                S0: begin // ����״̬
                    display <= 5'b00001;
                    cleaned <= off;
                    // ������ڲ˵�ģʽ�������л�״̬
                    if (menu && !in_menu_mode) begin
                        in_menu_mode <= 1;  // ����˵�ģʽ
                    end else if (in_menu_mode) begin
                        // �ڲ˵�ģʽ�°��°�ť�л���λ
                        if (state_01_stable) begin
                            State <= S1;
                            in_menu_mode <= 0; // �˳��˵�ģʽ
                        end else if (state_02_stable) begin
                            State <= S2;
                            in_menu_mode <= 0;
                        end else if (state_03_stable && !entered_S3) begin
                            State <= S3;
                            time_count_menu <= 0;
                            time_count_S2 <= 0;
                            entered_S3 <= 1;  // ����� S3 �󣬱��Ϊ 1
                            in_menu_mode <= 0;
                        end else if (state_clean_stable) begin
                            State <= S4;
                            time_count_clean <= 0;
                            in_menu_mode <= 0;
                        end
                    end else begin
                        State <= S0; // �����ڴ���״̬
                    end
                end

                S1: begin // һ��
                    display <= 5'b00010;
                    if (state_02_stable) begin
                        State <= S2;
                    end else if (menu) begin
                        State <= S0;
                    end else begin
                        State <= S1;
                    end
                end

                S2: begin // ����
                    display <= 5'b00100;
                    if (state_01_stable) begin
                        State <= S1;
                    end else if (menu) begin
                        State <= S0;
                    end else begin
                        State <= S2;
                    end
                end

                S3: begin // ����
                    display <= 5'b01000;
                    if (menu) begin
                        if (time_count_menu > wait_period_S3) begin
                            State <= S0;
                        end else begin
                            time_count_menu <= time_count_menu + 1;
                        end
                    end else begin
                        time_count_S2 <= time_count_S2 + 1;
                        if (time_count_S2 > wait_period_S3) begin
                            State <= S2;
                        end
                    end
                end

                S4: begin // �����
                    display <= 5'b10000;
                    if (time_count_clean > wait_period_clean) begin
                        cleaned <= on;
                        State <= S0;
                    end else begin
                        time_count_clean <= time_count_clean + 1;
                    end
                end

                default: begin
                    State <= S0;
                end
            endcase
        end else begin
            display <= 5'b00000;
            cleaned <= off;
            in_menu_mode <= 0;
            entered_S3 <= 0;  // ���� entered_S3
        end
    end
endmodule