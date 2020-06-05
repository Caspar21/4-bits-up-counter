//--------------------------------------------------------------------
//Design Name:Counter
//File Name  :4bitsupcounter.v
//Function   :4-bits up counter
//--------------------------------------------------------------------
module counter (clk, reset, enable, count);
input clk, reset, enable;             //輸入必須是wire的形式
output reg [3:0] count;               //輸出可以是wire或者是reg的形式

always @ (posedge clk)
if (reset == 1'b1) begin
   count <= 0;
end else if (enable == 1'b1) begin
   count <= count + 1;
end

endmodule