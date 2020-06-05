//--------------------------------------------------------------------
//Design Name:Counter testbench
//Function   :4-bits up counter
//--------------------------------------------------------------------
module counter_tb;  

    //宣告
    reg clk, reset, enable;     //test bench的輸入必須是reg的形式
    wire [3:0] count;           //test bench的輸出必須是wire的形式
    reg dut_error;
    reg [3:0] count_compare;    //for self ch
	 integer outf;               //file output
	 
    //實例化DUT
    counter uut(.clk(clk), .reset(reset), .enable(enable),.count(count));

    //命名事件控制
    event reset_trigger;         //定義一個reset_trigger事件
    event reset_done;            //定義一個reset_done事件
	 event reset_enable;          //定義一個reset_enable事件
    event terminate_sim;         //定義一個terminate_sim事件

    initial begin   //初始化測試的狀態, An initial block in Verilog is executed only once
	     outf = $fopen("Test Resuit.txt","w");
        $display("###################################################");
		  $fdisplay(outf, "###################################################");
        clk = 0;             
        reset = 0;
        enable = 0;
        dut_error = 0; 
		  #25 -> reset_trigger;
    end      
    always begin    //forever begin也可以用來產生連續clock
        #5 clk = !clk;
    end

    //記錄的波型寫入counter.vcd中，dumpvars則可以指定要記錄哪些信號的輸出
    initial begin
        $dumpfile("counter.vcd");
        $dumpvars;
    end
  
    //顯示出每一個時間, 信號的狀態
    initial begin
        $display("\ttime, \tclk, \treset, \tenable, \tcount");
		  $fdisplay(outf, "\ttime, \tclk, \treset, \tenable, \tcount");
        $monitor("%d, \t%b, \t%b, \t%b, \t%d", $time, clk, reset, enable, count);
		  $fmonitor(outf, "%d, \t%b, \t%b, \t%b, \t%d", $time, clk, reset, enable, count);	  
    end

    //產生reset事件
    initial begin
        forever begin
            @ (reset_trigger);
            @ (negedge clk);
                $display("Applying reset");
					 $fdisplay(outf, "Applying reset");
                reset = 1;
            @ (negedge clk)
                reset = 0;
                $display("Came out of Reset");
					 $fdisplay(outf, "Came out of Reset");
                -> reset_done;         //觸發reset_done事件
        end
    end

    //Test case, Assert/ De-assert enable after reset is applied
    initial begin
        #10 -> reset_enable;
        @ (reset_done);
        @ (negedge clk);
        enable = 1;
        repeat (15)
            begin
                @ (negedge clk);
            end
            enable = 0;
            #5 -> terminate_sim;
    end

    //self checking
    always @ (posedge clk)
    if (reset == 1'b1) begin
        count_compare <= 0;
    end else if (enable == 1'b1) begin
        count_compare <= count_compare + 1;
    end
   
    //there is any error, it prints out the expected and actual value,
    //and also terminates the simulation by triggering the event endmodule
    always @ (negedge clk)
    if (count_compare !== count) begin
        $display ("DUT Error at time %d", $time);
		  $fdisplay (outf, "DUT Error at time %d", $time);
        $display ("Expected value %d, Got Value %d", count_compare, count);
		  $fdisplay (outf, "Expected value %d, Got Value %d", count_compare, count);
        dut_error = 1;
        #5 -> terminate_sim;       //觸發terminate_sim事件
    end

    //顯示模擬結果
    initial @ (terminate_sim) begin
        $display ("Terminating simulation");
		  $fdisplay (outf, "Terminating simulation");
        if (dut_error == 0) begin
            $display ("Simulation Result : PASSED");
				$fdisplay (outf, "Simulation Result : PASSED");
        end
        else begin
            $display ("Simulation Result : FAILED");
				$fdisplay (outf, "Simulation Result : FAILED");
        end
        $display ("###################################################");
		  $fdisplay (outf, "###################################################");
		  $fclose(outf);
        #1 $finish;
    end
endmodule