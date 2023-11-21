/////////////////////////////////////////////////////////
/////////////////////////Custom testbenches//////////////
/////////////////////////////////////////////////////////


//These include the testbenches for all the earlier modules for operations
//and for the overall project and its submodules



module full_adder_8bit_tb;
  reg[7:0]t_a, t_b;
  wire[7:0]sum;
  reg cin;
  wire carry;
  full_adder_8bit dut(sum, carry, t_a, t_b, cin);
  initial begin
    $monitor($time, "a=%d, b=%d, cin=%d,fcarry_out=%d, fsum=%d\n", t_a, t_b, cin, carry, sum);
    //test cases
    t_a = 8'd56;
    t_b = 8'd42;
    cin = 1'b0;
    #5
    t_a = 8'd32;
    t_b = 8'd17;
    cin = 1'b0;
    #5
    t_a = 8'd47;
    t_b = 8'd70;
    cin = 1'b0;
    #5
    $stop;
  end
endmodule


module mymul_16bitgate_tb;
  reg[7:0]t_a,t_b;
  wire out;
  wire[15:0]t_mout;
  
  mymul_16bitgate dut(t_mout,out ,t_a, t_b);
  
  initial begin
    
    $monitor($time, "a=%d, b=%d, t_mout=%d\n",t_a, t_b, t_mout);
    // test cases
    t_a = 8'd32;
    t_b = 8'd46;
    #5
    t_a = 8'd2;
    t_b = 8'd3;
    #5
    t_a = 8'd11;
    t_b = 8'd3;
    #5
  $stop;
end 
endmodule



module full_adder_16bit_tb;
  reg[15:0]t_a, t_b;
  reg cin;
  wire carry;
  wire[15:0]sum;
  
  full_adder_16bit dut(sum, carry, t_a, t_b, cin);
  initial begin
    $monitor($time, "a=%d, b=%d,cin=%d, fcarry_out=%d, fsum=%d\n", t_a, t_b, cin, carry, sum);
    // test cases
    t_a = 16'd128;
    t_b = 16'd47;
    cin = 1'b0;
    #5;
    t_a = 16'd200;
    t_b = 16'd5;
    cin = 1'b0;
    #5;
  $stop;
end
endmodule




module full_lookaheadadder_4bit_tb;
  reg[3:0]t_a,t_b;
  reg cin;
  wire[3:0]t_sum;
  wire carry;
  
  full_lookaheadadder_4bit dut(t_sum, carry, t_a, t_b, cin);
  initial begin
    $monitor($time," a=%d, b=%d, cin=%d, sum=%d, carry_out=%d\n", t_a, t_b, cin, t_sum, carry);
    
    //test cases
    t_a = 4'b1000;
    t_b = 4'b1100;
    cin = 1'b0;
    #5;              // wait 5 units of time to execute next section of code
    
    t_a = 4'b1111;
    t_b = 4'b0000;
    cin = 1'b0;
    #5;
    
    t_a = 4'b1010;
    t_b = 4'b1110;
    cin = 1'b0;
    #5
    
    t_a = 4'b0010;
    t_b = 4'b0001;
    cin = 1'b0;
    #5
    $stop;
    
    
end
endmodule



module mymul_8bitgate_tb; 
  
  reg [3:0] t_a, t_b;
  wire [7:0] t_mout;
  wire cout;

  mymul_8bitgate dut(t_mout, cout, t_a, t_b); 

  initial begin 
    $monitor($time," a=%d, b=%d, mout=%d, cout=%d\n", t_a, t_b, t_mout, cout);

    // Test Case 1
    t_a = 4'b1111; 
    t_b = 4'b0001; 
    #5;

    // Test Case 2
    t_a = 4'b1111; 
    t_b = 4'b0010; 
    #5;

    // Test Case 3
    t_a = 4'b1111; 
    t_b = 4'b1111; 
    #5;

    // Add more test cases if needed

    // Terminate the simulation
    $stop;
  end 
endmodule



`timescale 1ns / 1ns  // Adjust timescale as needed

module proj1_tb;
  //inputs to drive test
  reg clk, rst;
  wire memRW;
  wire [7:0]memAddress;
  wire [15:0]memD;
  
  
  proj1 dut(clk, rst, memRW, memAddress, memD);
  
always
#5 clk = !clk;
initial begin
clk=1'b0;
rst=1'b1;
$readmemh("memory.list", proj1_tb.dut.r1.MEM);
#20 rst=1'b0;
#40000 //might need to be very large
//$display("Final value\n");

// all the display statements for each line in the memory file

$display("0x0000 %h\n",proj1_tb.dut.r1.MEM[16'h0000]);
$display("0x0001 %h\n",proj1_tb.dut.r1.MEM[16'h0001]);
$display("0x0002 %h\n",proj1_tb.dut.r1.MEM[16'h0002]);
$display("0x0003 %h\n",proj1_tb.dut.r1.MEM[16'h0003]);
$display("0x0004 %h\n",proj1_tb.dut.r1.MEM[16'h0004]);
$display("0x0005 %h\n",proj1_tb.dut.r1.MEM[16'h0005]);
$display("0x0006 %h\n",proj1_tb.dut.r1.MEM[16'h0006]);
$display("0x0007 %h\n",proj1_tb.dut.r1.MEM[16'h0007]);
$display("0x0008 %h\n",proj1_tb.dut.r1.MEM[16'h0008]);
$display("0x0009 %h\n",proj1_tb.dut.r1.MEM[16'h0009]);
$display("0x000A %h\n",proj1_tb.dut.r1.MEM[16'h000A]);
$display("0x000B %h\n",proj1_tb.dut.r1.MEM[16'h000B]);
$display("0x000C %h\n",proj1_tb.dut.r1.MEM[16'h000C]);
$display("0x000D %h\n",proj1_tb.dut.r1.MEM[16'h000D]);
$display("0x000E %h\n",proj1_tb.dut.r1.MEM[16'h000E]);
$display("0x000F %h\n",proj1_tb.dut.r1.MEM[16'h000F]);
$display("0x0010 %h\n",proj1_tb.dut.r1.MEM[16'h0010]);  // only thing that actually gets the value


$finish;
end

endmodule





module RAM_tb;
    
  reg enable;    //we
  reg[15:0]t_d;  // d
  reg[7:0]addy;  // address
  wire[15:0]out;  // output
  
  ram dut(out, enable, t_d, addy);
  
  initial begin
   
    enable = 1;
    t_d = 16'h000A;
    addy = 8'h0F;
    #35;
    
    enable = 0;
    addy = 8'h0F;
    #35;
    
    $stop;
    
    
    
    
  end
endmodule





module registers_tb;
  //module inputs
  reg clk, rst, zflag;
  reg[7:0]PC, MAR;
  reg[15:0]IR, ACC, MDR;
  
  //module outputs
  wire[7:0]PC_out, MAR_out;
  wire[15:0]IR_out, ACC_out, MDR_out;    
  wire zflag_out;  
  
  registers dut(clk, rst, PC_out, PC, IR_out, IR, ACC_out, ACC, MDR_out, MDR, MAR_out, MAR, zflag_out, zflag);
  initial begin
    $monitor($time, "resst=%d, PCin=%d, PCout=%d, IRin=%d, IRout=%d ACCin=%d, ACCout=%d, MDRin=%d, MDRout=%d, MARin=%d, MARout=%d, zflagin=%d, zflagout=%d", 
    rst, PC, PC_out, IR, IR_out, ACC, ACC_out, MDR, MDR_out, MAR, MAR_out, zflag, zflag_out);
    
    // test cases for the test bench
    clk = 0; // start clock
    rst = 0;
    PC = 1;
    IR = 1;
    ACC = 1;
    MDR = 1;
    MAR = 1;
    zflag = 1;
    #15;
    
    rst = 0;
    PC = 2;
    IR = 2;
    ACC = 2;
    MDR = 2;
    MAR = 2;
    zflag = 2;
    #15;
    
    rst = 1;
    #20;
    
    $stop;

end

always #5 clk = ~clk; // clock cycle

endmodule




module ALU_TB;
 reg[15:0]t_a, t_b;
  reg[3:0]op;
  wire [15:0]out;

 
 alu dut(t_a, t_b, op, out);
 initial begin 
    $monitor($time," A=%d, B=%d, opALU=%d, Rout=%d\n", t_a, t_b, op, out);  // log the inputs and outputs
    
 
    // test cases
    t_a = 16'b1000_1111_1111;
    t_b = 16'b1111;
    op = 3'd2;      // add

    #5;
    
   
    
    $stop;
  end
endmodule 








