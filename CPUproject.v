// Project #1 Simplified CPU 
// Colin McMillen  10/31/23  
// This project is to understand the basic properties and functions of a simplified CPU


/*
General project notes:
@0000 0A09 //Load 8 in to ACC
each address is 16 bits, in this line, the @ designates the address
the instructions are 16 bits, 4 hex bits, 0A09
The last 8 bits are the opcode
The first 8 bits are the address operand

-These are the supported Instructions
0x01 ADD
0x02 SUB
0x03 MUL
0x04 DIV  // no longer required, but still implement with inferred verilog
0x05 XOR
0x6 JUMP
0x7 JUMPZ
0x8 STORE
0x9 LOAD
*/



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


module mux_4bit (output [3:0] Out, 
 input [3:0] A, B, input sel);
 // no internal nets or registers 
 mux_2 m3 (Out[3], A[3], B[3], sel);
 mux_2 m2 (Out[2], A[2], B[2], sel);
 mux_2 m1 (Out[1], A[1], B[1], sel);
 mux_2 m0 (Out[0], A[0], B[0], sel);
endmodule

module mux_8bit (output [7:0] Out, input [7:0]B,A, input sel); 
  mux_4bit m2(Out[7:4], A[7:4], B[7:4], sel);
  mux_4bit m1(Out[3:0], A[3:0], B[3:0], sel);
endmodule



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

 






























//Module 1 RAM: 
// all instructions are assumed to be present in memory

// given an address, we read from it or we write to it
// depending upon what the WE signal is, that will determine whether we read or write
// if we read, then we input a random d, the address that we want to read / write to, set we to 0
// then we copy the contents in the address to the output q. 
// if we write, then we input an address to write to, set d = to the stuff we want to write,
// set we to 1 and we get a random q output. 
// 256X16 for the size of the sample intstruction file to be inserted


// Module Complete
module ram (q,we,d,address);
input we;               // 1 bit read and write enable, 0 = read, 1 = write
input [15:0]d;          // 16 bit data input
output reg[15:0]q;          // 16 bit data output
input [7:0]address;       // 8 bit input address

// actual memory register
reg[15:0]MEM[0:255]; // 256 16 bit words, address isn't included in that 16 bits


always@(*) 
begin
  if(we) // write
    begin 
        
        MEM[address] <= d;  // memory at given address is equal to the input value, d 
    
    end
	else  q <= MEM[address]; 
  end
endmodule





//Module 2 ALU:
module alu(A,B,opALU, Rout);
input [15:0]A, B;   // 16 bit inputs
input [2:0]opALU;   
output reg[15:0]Rout;  // the output of the instruction

//multipler wires
wire cout;
wire [15:0]mulOut;

//adder wires
wire [15:0]sum;
wire carry_out;
//assuming cin is always 0;

// subtractor wires
wire [15:0]sub;
wire sub_carry_out;

	//full_adder_16bit a1();  // 16 bit adder and works as subtractor too, need a negation
mymul_16bitgate m1(mulOut, cout, A[7:0], B[7:0]); //  16 bit multipler, only uses the 8 LSB of A and B as 8 bit inputs
full_adder_16bit a1(sum, carry_out, A, B, 1'b0);      // 166 bit adder, uses all 16 bits of both A and B, cin of 0 
full_adder_16bit s1(sub, sub_carry_out, A, ~B, 1'b1); // 16 bit subtractor, uses all 16 bits, needs a cin of 1



//prase through the instruction set to get the correct command
always@(*)
  begin
  if     (opALU == 1) Rout <= sum;        // if add
  else if(opALU == 2) Rout <= sub;        // if sub 
  else if(opALU == 3) Rout <= mulOut;        // if mul
  else if(opALU == 4) Rout <= A / B;        // div, not used so using inferred verilog logic here
  else if(opALU == 5) Rout <= A ^ B;        // xor , allowed to use this operator
  end
  


endmodule 




//Module 3 Controler: This module acts as one big enable for the
// different muxes, MAR's, MDR's, reads, and writes. 

module ctr (
clk,
rst,
zflag,
opcode,
muxPC,
muxMAR,
muxACC,
loadMAR,
loadPC,
loadACC,
loadMDR,
loadIR,
opALU,
MemRW
);
input clk;
input rst;
input zflag;
input [7:0]opcode;
output reg muxPC;
output reg muxMAR;
output reg muxACC;
output reg loadMAR;
output reg loadPC;
output reg loadACC;
output reg loadMDR;
output reg loadIR;
output reg[2:0]opALU;
output reg MemRW;




//5 state bits to implement, 19 states

parameter   //based upon the image used in the assignment

fetch1 = 5'b0, fetch2 = 5'b1, 
fetch3 = 5'b10, decode = 5'b11, 
add1 = 5'b100, add2 = 5'b101, 
sub1 = 5'b110, sub2 = 5'b111, 
mul1 = 5'b1000, mul2 = 5'b1001,
div1 = 5'b1010, div2 = 5'b1011,
xo1 = 5'b1100, xo2 = 5'b1101,
jmp = 5'b1110, jmpz = 5'b1111,
str = 5'b10000, load1 = 5'b10001, 
load2 = 5'b10010;


reg[4:0] current_state, next_state; // registers for the always blocks

// always block to update values of current state
always@(posedge clk)begin       
  if (rst) begin
      current_state <= fetch1;
    end
    else
      current_state <= next_state;

  end  
  
  // turn off all the things set to 1 in the previous state
  
always@(current_state)begin
  case (current_state)
    
    fetch1: begin 
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b1; 
            loadPC <= 1'b1; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            next_state <= fetch2;
            end
    fetch2: begin
      
            // turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            
            
            loadMDR <= 1;
            next_state <= fetch3;
            end
    fetch3: begin
            //turn off the pverious enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
      
            loadIR <= 1;
            next_state <= decode;
            end 
    decode: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            
            muxMAR  <= 1;
            loadMAR <= 1;
            // if statement for opcode, mux within a mux, maybe not optimized
                 if(opcode==1) next_state <= add1;
            else if(opcode==2) next_state <= sub1;
            else if(opcode==3) next_state <= mul1;  
            else if(opcode==4) next_state <= div1;
            else if(opcode==5) next_state <= xo1;
            else if(opcode==6) next_state <= jmp;
            else if(opcode==7) next_state <= jmpz;
            else if(opcode==8) next_state <= str;
            else if(opcode==9) next_state <= load1;
            end 
      add1: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
          
            loadMDR <= 1;
            next_state <= add2;
            end
      add2: begin
           //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            loadACC <= 1;
            opALU = 1;
            
            next_state <= fetch1;
            end
      sub1: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            loadMDR <= 1;
            next_state <= sub2;
            end
      sub2: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
        
            loadACC <= 1;
            opALU = 2;
            next_state <= fetch1;
            end
      mul1: begin
         //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
          
            loadMDR <= 1;
            next_state <= mul2;
            end
      mul2: begin
            //turn off the previous enables
           muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            loadACC <= 1;
            muxACC <= 0;
            opALU = 3;
            next_state <= fetch1;
            end
      div1: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            MemRW   <= 0;
            loadMDR <= 1;
            next_state <= div2;
            end
      div2: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            loadACC <= 1;
            muxACC <= 0;
            opALU = 4;
            next_state <= fetch1;
            end
       xo1: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            MemRW   <= 0;
            loadMDR <= 1;
            next_state <= xo2;
            end
       xo2: begin
          //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            loadACC <= 1;
            opALU = 5;
            next_state <= fetch1;
            end
       jmp: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            muxPC  <= 1;
            loadPC <= 1;
            
            next_state <= fetch2;
            end
      jmpz: begin
           //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
        
            
            if(zflag==1) next_state <= jmp;
            else if(zflag==0) next_state <= fetch1;
            end
       str: begin
		      muxPC = 1'b0; 
          muxMAR = 1'b0; 
          muxACC = 1'b0; 
          loadMAR = 1'b0; 
          loadPC = 1'b0; 
          loadACC = 1'b0; 
          loadMDR = 1'b0; 
          loadIR = 1'b0; 
          opALU = 3'b0; 
          
          MemRW = 1'b1; 
          
          next_state <= fetch1;
            end
     load1: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            loadMDR <= 1;
            next_state <= load2;
            end
     load2: begin
            //turn off the previous enables
            muxPC <= 1'b0; 
            muxMAR <= 1'b0; 
            muxACC <= 1'b0; 
            loadMAR <= 1'b0; 
            loadPC <= 1'b0; 
            loadACC <= 1'b0; 
            loadMDR <= 1'b0; 
            loadIR <= 1'b0; 
            opALU <= 3'b0; 
            MemRW <= 1'b0; 
            
            loadACC <= 1;
            muxACC <= 1;
            next_state <= fetch1;
            end
    default: begin 
             next_state <= fetch1;
             end
  endcase
end
endmodule


//Module 4 Register Bank:
// very self explainitory here
// this module is complete
module registers(
clk,
rst,
PC_reg,
PC_next,
IR_reg,
IR_next,
ACC_reg,
ACC_next,
MDR_reg,
MDR_next,
MAR_reg,
MAR_next,
zflag_reg,
zflag_next
);
input wire clk;
input wire rst;
output reg [7:0]PC_reg;
input wire [7:0]PC_next;
output reg [15:0]IR_reg;
input wire [15:0]IR_next;
output reg [15:0]ACC_reg;
input wire [15:0]ACC_next;
output reg [15:0]MDR_reg;
input wire [15:0]MDR_next;
output reg [7:0]MAR_reg;
input wire [7:0]MAR_next;
output reg zflag_reg;
input wire zflag_next;




always@(posedge clk)begin
  if(rst) begin// set all registers back to zero
    PC_reg    <= 0;
    IR_reg    <= 0;
    ACC_reg   <= 0;
    MDR_reg   <= 0;
    MAR_reg   <= 0;
    zflag_reg <= 0;
  end
  else begin
    PC_reg    <= PC_next;
    IR_reg    <= IR_next;
    ACC_reg   <= ACC_next;
    MDR_reg   <= MDR_next;
    MAR_reg   <= MAR_next;
    zflag_reg <= zflag_next;
  end 
end
endmodule 



//Module 5 Datapath:
//Data path: the next values are generated
// for all the reigsters and the singles 
// to drive all the muxes, generating new values
// for the hardware



module datapath(
clk,
rst,
muxPC,
muxMAR,
muxACC,
loadMAR,
loadPC,
loadACC,
loadMDR,
loadIR,
opALU,
zflag,
opcode,
MemAddr,
MemD,
MemQ
);
//inputs
input clk;
input rst;
input muxPC;
input muxMAR;
input muxACC;
input loadMAR;
input loadPC;
input loadACC;
input loadMDR;
input loadIR;
input [2:0]opALU;
input [15:0]MemQ;
// outputs
output zflag;
output [7:0]opcode;
output [7:0]MemAddr;
output [15:0]MemD;
// interim values
reg [7:0]PC_next;
wire [15:0]IR_next; // this
reg [15:0]ACC_next;
wire [15:0]MDR_next; //this 
reg [7:0]MAR_next;
reg zflag_next;
wire [7:0]PC_reg;
wire [15:0]IR_reg;
wire [15:0]ACC_reg;
wire [15:0]MDR_reg;
wire [7:0]MAR_reg;
wire zflag_reg;
wire [15:0]ALU_out;




alu a1(ACC_reg,MDR_reg,opALU,ALU_out);
registers r1(clk, rst, PC_reg, PC_next, IR_reg, IR_next, ACC_reg, ACC_next, MDR_reg, MDR_next, MAR_reg, MAR_next, zflag_reg, zflag_next);



always@(*) begin
if(loadPC) 
PC_next <= muxPC ? IR_reg[15:8]:(PC_reg+1'b1);  //correct
else PC_next <= PC_reg;

//Acc next
if(loadACC) ACC_next <= muxACC ? MDR_reg: ALU_out;   //correct
else ACC_next <= ACC_reg;

//Mar next
if(loadMAR)MAR_next <= muxMAR? IR_reg[15:8]:PC_reg; // correct
else MAR_next <= MAR_reg;

//zflag
if(ACC_reg==0) zflag_next<=1;
else zflag_next <= 0;
  end

assign IR_next = loadIR ? MDR_reg : IR_reg; // correct
assign MDR_next = loadMDR ? MemQ : MDR_reg; // correct

assign zflag = zflag_reg; 
assign opcode = IR_reg[7:0]; 
assign MemAddr = MAR_reg;     
assign MemD = ACC_reg;

endmodule






//Module 6 High Level: 

module proj1(clk,rst,MemRW_IO,MemAddr_IO,MemD_IO);  // one instance of each 
input clk, rst;
output MemRW_IO;        // instance of memory
output [7:0]MemAddr_IO; // instance of controller
output [15:0]MemD_IO;   // instance of datapath

// interim values
wire zflag,muxPC,muxMAR,muxACC,loadMAR,loadPC,loadACC,loadMDR,loadIR,MemRW;
wire[2:0] opALU;
wire[7:0] opcode,MemAddr;
wire[15:0] MemD,MemQ; // for the memory / ram module 

// instance of memory
ram r1(MemQ,MemRW,MemD,MemAddr);
// instance of controller
ctr c1(clk, rst, zflag, opcode, muxPC, muxMAR, muxACC, loadMAR, loadPC, loadACC, loadMDR, loadIR, opALU, MemRW);
// instance of datapath
datapath d1(clk, rst, muxPC, muxMAR, muxACC, loadMAR, loadPC, loadACC, loadMDR, loadIR, opALU,zflag,opcode,MemAddr, MemD, MemQ);


assign MemAddr_IO = MemAddr;
assign MemD_IO = MemD;
assign MemRW_IO = MemRW;

endmodule





// my custom test benches below



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


