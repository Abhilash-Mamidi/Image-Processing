module image (
    input wire clk,
    input wire reset, // Active Low Reset
    input wire pixel_valid,
    input wire [23:0] pixel_input,
    
    output reg [23:0] avg_pixel,
    output reg done
);
    // Internal registers
    reg [31:0] sum_r, sum_g, sum_b;
    reg [31:0] pixel_count;
    reg processing;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            sum_r <= 0;
            sum_g <= 0;
            sum_b <= 0;
            pixel_count <= 0;
            processing <= 0;
            done <= 0;
        end 
        else begin
            done <= 0; // Default assignment
            
            if (pixel_valid) begin
                sum_r <= sum_r + pixel_input[23:16];
                sum_g <= sum_g + pixel_input[15:8];
                sum_b <= sum_b + pixel_input[7:0];
                pixel_count <= pixel_count + 1;
                processing <= 1;
            end 
            else if (processing) begin
                // Calculating average with rounding
                avg_pixel[23:16] <= (sum_r + (pixel_count >> 1)) / pixel_count;
                avg_pixel[15:8]  <= (sum_g + (pixel_count >> 1)) / pixel_count;
                avg_pixel[7:0]   <= (sum_b + (pixel_count >> 1)) / pixel_count;
                done <= 1;
                processing <= 0;
            end
        end
    end
endmodule
