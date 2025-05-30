module tb_image;

    // Clock generation
    reg clk = 0;
    always #5 clk = ~clk;
    
    // DUT connections
    reg reset = 0;
    reg [23:0] pixel_input;
    reg pixel_valid;
    wire [23:0] avg_pixel;
    wire done;
    
    // File handling
    integer input_file, output_file;
    integer total_pixels;
    real ref_avg_r, ref_avg_g, ref_avg_b;

    // DUT Instantiation
    image dut (
        .clk(clk),
        .reset(reset),
        .pixel_valid(pixel_valid),
        .pixel_input(pixel_input),
        .avg_pixel(avg_pixel),
        .done(done)
    );

    initial begin
        reset = 0;
        pixel_valid = 0;
        total_pixels = 0;
        #20 reset = 1;
        
        // Opening files
        input_file = $fopen("image.hex", "r");
        if (input_file == 0) begin
            $display("Error: Cannot open input file");
            $finish;
        end
        
        output_file = $fopen("output.hex", "w");
        if (output_file == 0) begin
            $display("Error: Cannot create output file");
            $finish;
        end
        
        // Calculating reference average
        calculate_reference();
        
        // Processing image
        process_image();
        
        // Verifying results
        verify_output();
        
        $display("Simulation completed successfully");
        $finish;
    end
    
    // Task to calculate reference average
    task calculate_reference;
        reg [23:0] px;
        real r, g, b;
        integer data_valid;
        begin
            r = 0; g = 0; b = 0;
            data_valid = 1;
            while (!$feof(input_file) && data_valid) begin
                if ($fscanf(input_file, "%h\n", px) == 1) begin
                    r = r + px[23:16];
                    g = g + px[15:8];
                    b = b + px[7:0];
                    total_pixels = total_pixels + 1;
                end
                else begin
                    data_valid = 0;
                end
            end
            ref_avg_r = r / total_pixels;
            ref_avg_g = g / total_pixels;
            ref_avg_b = b / total_pixels;
            $display("Reference Average: R=%0d G=%0d B=%0d",
                $rtoi(ref_avg_r), $rtoi(ref_avg_g), $rtoi(ref_avg_b));
                
            // Reopening the file for processing
            $fclose(input_file);
            input_file = $fopen("image.hex", "r");
        end
    endtask
    
    // Task for processing image
    task process_image;
        reg [23:0] px;
        integer data_valid;
        begin
            data_valid = 1;
            pixel_valid = 1;
            
            while (!$feof(input_file) && data_valid) begin
                if ($fscanf(input_file, "%h\n", px) == 1) begin
                    pixel_input = px;
                    @(posedge clk);
                end 
                else begin
                    data_valid = 0;
                end
            end
            
            pixel_valid = 0;
            while (!done) begin
                @(posedge clk);
            end
            
            // Writing the output value into the output file
            begin : write_output
                integer i;
                for (i = 0; i < total_pixels; i = i + 1) begin
                    $fdisplay(output_file, "%06X", avg_pixel);
                end
            end
        end
    endtask
    
    // Task for Verifying the output with Golden Reference
    task verify_output;
        real error_r, error_g, error_b;
        begin
            error_r = ref_avg_r - avg_pixel[23:16];
            error_g = ref_avg_g - avg_pixel[15:8];
            error_b = ref_avg_b - avg_pixel[7:0];
            
            $display("\nVerification Results:");
            $display("DUT Average: R=%02X G=%02X B=%02X",
                avg_pixel[23:16], avg_pixel[15:8], avg_pixel[7:0]);
            
            if (error_r > 0.5 || error_r < -0.5 ||
                error_g > 0.5 || error_g < -0.5 ||
                error_b > 0.5 || error_b < -0.5) begin
                $display("Error: Mismatch with reference");
            end 
            else begin
                $display("Success: Output matches reference");
            end
        end
    endtask
endmodule
