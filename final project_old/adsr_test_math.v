module adsr_test_math();

    reg signed [15:0] sample_in, sample, usample;
    reg signed [37:0] sample_out;
    reg signed [29:0] product;
    reg signed [22:0] shift;
    reg [7:0] factor;

    initial begin
        factor = 8'd128;
        sample_in = 16'sb0;
        usample = (sample_in[15])
          ? ~(sample_in-16'b1) : sample_in;
        shift = {usample, 7'b0}>>>7;
        product = {factor, 7'b0}*shift;
        repeat(17) begin
            repeat(17) begin
                sample_out = {usample, 14'b0}-product;
                sample = (sample_in[15])
                  ? ~(sample_out[28:14])+1'b1
                  : sample_out[29:14];
                $display("in %d, fact %d, out %d",
                    sample_in, factor, sample);
                if (factor >= 128/16) factor = factor - (128/16);
                else factor = 8'd128;
                product = {factor, 7'b0}*shift;
            end
            sample_in = sample_in + (65536/16);
            usample = (sample_in[15])
              ? ~(sample_in-16'b1) : sample_in;
            shift = {usample, 7'b0}>>>7;
            product = {factor, 7'b0}*shift;
        end

        $finish;
    end

endmodule
