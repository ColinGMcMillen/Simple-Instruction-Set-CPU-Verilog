// these are all the other homework modules used in the project 1 ALU
module half_adder(sum, carry, a, b); 
input a, b; 
output sum, carry; 
xor sum1(sum, a, b); 
and carry1(carry, a, b); 
endmodule

module full_adder_1bit(fsum, fcarry_out, a, b, c); 
input a, b, c; 
output fsum, fcarry_out; 
wire half_sum_1, half_carry_1, half_carry_2; 
half_adder HA1(half_sum_1, half_carry_1, a, b); //instance 1 of Half Adder
half_adder HA2(fsum, half_carry_2, half_sum_1, c); //instance 2 of Half Adder
or or1(fcarry_out, half_carry_2,half_carry_1); 
endmodule

module full_adder_4bit(fsum, fcarry_out, a, b, cin); 
input [3:0]a, b;
input cin;
output [3:0]fsum;
output fcarry_out; 
wire cb0, cb1, cb2;
full_adder_1bit B3(fsum[3], fcarry_out, a[3], b[3], cb2);
full_adder_1bit B2(fsum[2], cb2, a[2], b[2], cb1);
full_adder_1bit B1(fsum[1], cb1, a[1], b[1], cb0);
full_adder_1bit B0(fsum[0], cb0, a[0], b[0], cin);
endmodule

////////////////////////////////////////////////////////////////////////////////

 module full_lookaheadadder_4bit(fsum, fcarry_out, a, b, cin); 
input [3:0]a, b;
input cin;
output reg [3:0]fsum;
output reg fcarry_out; 
reg [3:0]p, g;
reg [4:0] c;
always @(*) begin
 p = a ^ b;
 g = a & b;
 c[0] = cin;
 c[1] = g[0] | (p[0] & c[0]);
 c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
 c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
 c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & 
c[0]);
 fsum = p ^ c[3:0];
 fcarry_out = c[4];
end
endmodule
 
 
////////////////////////////////////////////////////////////////////////////////


module mux_2 (output out, input i0, i1, sel); 
 wire n_sel, x1, x2; // internal nets
 or (out, x1, x2); // output
 and (x1, i0, n_sel); // i0 & (~sel)
 and (x2, i1, sel); // i1 & sel
 endmodule


// 4 bit mux works just fine, test bench works
module mux_4bit (output [3:0] Out, 
 input [3:0] A, B, input sel);
 // no internal nets or registers 
 mux_2 m3 (Out[3], A[3], B[3], sel);
 mux_2 m2 (Out[2], A[2], B[2], sel);
 mux_2 m1 (Out[1], A[1], B[1], sel);
 mux_2 m0 (Out[0], A[0], B[0], sel);
endmodule

//try this for the 16bit multiplier!
module mux_8bit (output [7:0] Out, input [7:0]B,A, input sel); 
  mux_4bit m2(Out[7:4], A[7:4], B[7:4], sel);
  mux_4bit m1(Out[3:0], A[3:0], B[3:0], sel);
endmodule

// it wasn't specified in the directions if this should be 
// two 8bit muxes, or 4 4bit muxes, so I did 4 4bit muxs.
// 16 bit mux works, A and b had to be flipped, be careful in the future for this issue
module mux_16bit (output [15:0] Out, input [15:0]A,B, input sel); 
  mux_4bit m1(Out[15:12], A[15:12], B[15:12], sel);
  mux_4bit m2(Out[11:8], A[11:8], B[11:8], sel);
  mux_4bit m3(Out[7:4], A[7:4], B[7:4], sel);
  mux_4bit m4(Out[3:0], A[3:0], B[3:0], sel);
endmodule


// testing 16bit adder, this cuased issues due to the CLA 4 bit adder!!
module full_adder_8bit(fsum, fcarry_out, a, b, cin); 
  input [7:0]a, b;
  input cin;
  output [7:0]fsum;
  output fcarry_out;
  wire cb0;
  full_lookaheadadder_4bit FA41(fsum[3:0], cb0, a[3:0], b[3:0], cin);   // first 4 bit adder
  full_lookaheadadder_4bit FA42(fsum[7:4], fcarry_out, a[7:4], b[7:4], cb0);  // second 4 bit adder
endmodule



//16 bit adder is fully working now!
module full_adder_16bit(fsum, fcarry_out,a,b, cin);
  input [15:0]a,b;
  input cin;
  output [15:0]fsum;
  output fcarry_out;
  wire connect; //connect both instances of the 8 bit adder together
  full_adder_8bit a1(fsum[7:0],connect,a[7:0],b[7:0], cin);
  full_adder_8bit a2(fsum[15:8],fcarry_out,a[15:8],b[15:8], connect);
endmodule


module mymul_8bitgate(mout,cout,a,b);
 
  input [3:0]a,b;
  output [7:0]mout;
  output cout;
  wire [7:0]fsum_p1, fsum_p2, fsum_p3;
  wire fcarryout_p1, fcarryout_p2, fcarryout_p3;
  wire [3:0]m0, m1, m2, m3;
  
  
  
 // output, input, input, select
  mux_4bit mux1(m0,a,{4{1'b0}}, b[0]);    // 2 to 1 mux that takes two 4 bit inputs
  mux_4bit mux2(m1,a,{4{1'b0}}, b[1]);
  mux_4bit mux3(m2,a,{4{1'b0}}, b[2]);
  mux_4bit mux4(m3,a,{4{1'b0}}, b[3]);
  

  full_adder_8bit a1(fsum_p1,fcarryout_p1,{8{1'b0}},{{4{1'b0}},m0}, 1'b0);
  full_adder_8bit a2(fsum_p2,fcarryout_p2,fsum_p1,{{3{1'b0}},m1,{1{1'b0}}},fcarryout_p1);
  full_adder_8bit a3(fsum_p3,fcarryout_p3,fsum_p2,{{2{1'b0}},m2,{2{1'b0}}}, fcarryout_p2);
  full_adder_8bit a4(mout,cout,fsum_p3,{{1{1'b0}},m3,{3{1'b0}}}, fcarryout_p3);
  
  
endmodule


module mymul_16bitgate(mout, cout, a, b);
  input [7:0]a,b;
  output [15:0]mout;
  output cout;
  wire [15:0]fsum_p1, fsum_p2, fsum_p3, fsum_p4, fsum_p5,fsum_p6,fsum_p7,fsum_p8;
  wire fcarryout_p1, fcarryout_p2, fcarryout_p3, fcarryout_p4, fcarryout_p5, fcarryout_p6,fcarryout_p7;
  wire [7:0]m0, m1, m2, m3, m4, m5, m6, m7;


mux_8bit mux1(m0,a, {8{1'b0}},b[0]); 
mux_8bit mux2(m1,a, {8{1'b0}},b[1]);  
mux_8bit mux3(m2,a, {8{1'b0}},b[2]);  
mux_8bit mux4(m3,a, {8{1'b0}},b[3]);
mux_8bit mux5(m4,a, {8{1'b0}},b[4]); 
mux_8bit mux6(m5,a, {8{1'b0}},b[5]);  
mux_8bit mux7(m6,a, {8{1'b0}},b[6]);  
mux_8bit mux8(m7,a, {8{1'b0}},b[7]);

 
full_adder_16bit a1(fsum_p1,fcarryout_p1,{16{1'b0}},{{8{1'b0}},m0}, 1'b0);
full_adder_16bit a2(fsum_p2,fcarryout_p2,fsum_p1,{{7{1'b0}},m1,{1{1'b0}}}, fcarryout_p1);
full_adder_16bit a3(fsum_p3,fcarryout_p3,fsum_p2,{{6{1'b0}},m2,{2{1'b0}}}, fcarryout_p2);
full_adder_16bit a4(fsum_p4,fcarryout_p4,fsum_p3,{{5{1'b0}},m3,{3{1'b0}}}, fcarryout_p3);
full_adder_16bit a5(fsum_p5,fcarryout_p5,fsum_p4,{{4{1'b0}},m4,{4{1'b0}}}, fcarryout_p4);
full_adder_16bit a6(fsum_p6,fcarryout_p6,fsum_p5,{{3{1'b0}},m5,{5{1'b0}}}, fcarryout_p5);
full_adder_16bit a7(fsum_p7,fcarryout_p7,fsum_p6,{{2{1'b0}},m6,{6{1'b0}}}, fcarryout_p6);
full_adder_16bit a8(mout,cout,fsum_p7,{{1{1'b0}},m7,{7{1'b0}}}, fcarryout_p7);

endmodule




/////////////////////////////////////////////////////////
/////////////////////////Custom testbenches//////////////
/////////////////////////////////////////////////////////






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









