`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2020 12:09:21
// Design Name: 
// Module Name: top
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


// I need those values az global like multi dimensional array
package my_pkg;
    logic [15:0][7:0] value = {8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00, 8'b00};
    logic [7:0] finalSum = 8'b00;
    
    logic [19:0] reloadCount; //start counter from 0 to 20
    logic [1:0] activatingLeds; // led counter from 0 to 1 and make them activate
    logic [3:0] binToDec; //4 bit because there are 16 option. So, 2^4=16. Binaary to decimal
     
    logic [7:0] myCount; // counter for 10 second
    
    logic [4:0] displayMyCount = 0;
    logic displayMyCountCheck; // like a boolean to check if counter is displaying or not
    
    logic [4:0] dispChecksum = 0;
    logic dispCheckSumCheck; // like a boolean to check if checksum is displaying or not
       
    logic [26:0] countAsec;
    logic aSecCountCheck; 

    logic summing = 0;
    logic summingCheck; // sum is done or not for if control
endpackage


module top(input clk, // clock signal
           input logic btnL, btnR, btnU, btnC, btnD, //buttons to maanage fpga
           input logic [3:0] swA, // switches for address
           input logic [7:0] swD, //switches for data
           output logic [6:0] sevSeg, // 7-segment
           output logic [3:0] fourDigit, // anot
           output logic [3:0] ledA,// leds for address
           output logic [7:0] ledD // leds fordata
           );
           
    import my_pkg::value;
    import my_pkg::finalSum;
    import my_pkg::reloadCount;
    import my_pkg::activatingLeds; // led counter from 0 to 1 and make them activate
    import my_pkg::binToDec; //4 bit because there are 16 option. So, 2^4=16. Binaary to decimal
    import my_pkg::myCount; // counter for 10 second
    import my_pkg::displayMyCount;
    import my_pkg::dispChecksum;
    import my_pkg::dispCheckSumCheck; // like a boolean to check if checksum is displaying or not
    import my_pkg::displayMyCountCheck; // like a boolean to check if counter is displaying or not
    import my_pkg::countAsec; //
    import my_pkg::aSecCountCheck; 
    import my_pkg::summing;
    import my_pkg::summingCheck; // sum is done or not for if control
   
    integer i;
    
    always @(posedge clk)
    begin
        if(countAsec>=99999999) 
             countAsec <= 0; // turn back to head from tail
        else
             countAsec <= countAsec + 1; // move counter
    end 
    
    assign aSecCountCheck = (countAsec==99999999)?1:0; // statement check and assign accourdingly
    
    always @(posedge clk)
    begin
        reloadCount <= reloadCount + 1; // next count
    end
    assign activatingLeds = reloadCount[19:18]; // get the last value to find most significat
    
    always @(posedge clk)
    begin
       if (btnC)
            value[swA] <= swD; // center button to insert value from switch
        if (btnD)
            displayMyCount <= 10; // Down button to display 10 second counter
        if (btnU & summing == 0)
        begin
            i <= 0;
            myCount <= 0;
            finalSum <= 0;
            summing <= 1; // summing initialized for if control
        end
        
        if (summing)
        begin
            finalSum <= finalSum + value[i]; // calculating total by adding values subsequently
            i <= i + 1; // move up i
            if (i == 16) // 4 bit check
            begin
               finalSum <= ~finalSum + 1; // two's complemet
               summing <= 0; // make summing vareiable inactive
               dispChecksum <= 10; // 10 second to display the total
            end
        end 
        if (aSecCountCheck==1) // check if one second check is done
        begin
            if(dispChecksum>0)
                dispChecksum <= dispChecksum - 1;
            if(displayMyCount>0)
                displayMyCount <= displayMyCount - 1;  // timer 10 to 0
        end
    end
    assign dispCheckSumCheck = (dispChecksum!=0);
    assign displayMyCountCheck = (displayMyCount!=0);
    assign summingCheck = (summing == 1);
    
    
    always @(*)
    begin
        if (summingCheck)
           myCount = myCount + 1;
        case(activatingLeds)      // anotes are encoded like states
       2'b11:          //  the anot that I want to light up
            begin
                fourDigit = 4'b1110;   
                if (displayMyCountCheck) // if count is displaying or not
                    binToDec = myCount[3:0];  
                else if (dispCheckSumCheck)  // if sum is displaying or not
                    binToDec = finalSum[3:0];
                else if (btnR) // check next value
                    binToDec = value[swA+1][3:0];
                else if (btnL) // check previous value
                    binToDec = value[swA-1][3:0];
                else 
                    binToDec = value[swA][3:0];
            end
        2'b10:       //  the anot that I want to light up
            begin
                fourDigit = 4'b1101;     
                if (displayMyCountCheck)  // if count is displaying or not
                    binToDec = myCount[7:4];
                else if (dispCheckSumCheck)  // if sum is displaying or not
                    binToDec = finalSum[7:4];
                else if (btnR) // check next value
                    binToDec = value[swA+1][7:4];
                else if (btnL)   // check previous value
                    binToDec = value[swA-1][7:4];
                else
                    binToDec = value[swA][7:4];
            end
       2'b01:     //  the anot that I want to light up
            begin
                fourDigit = 4'b1011;   // dash or equal
                binToDec = 4'b0000; 
            end
        2'b00:      //  the anot that I want to light up
            begin
                fourDigit = 4'b0111;
                if (displayMyCountCheck)   // if count is displaying or not
                    binToDec = displayMyCount;
                else if (dispCheckSumCheck)  // if sum is displaying or not
                    binToDec = 4'b1100;
                else if (btnR)  // check next value
                    binToDec = swA + 1; // move up address
                else if (btnL)  // check previous value
                    binToDec = swA - 1; // move down address
                else
                    binToDec = swA; // made equal with address
            end
        endcase
    end
//Taken from unilica
   always @(*)
   begin
     case(binToDec)       //GFEDCBA
         4'b0000: sevSeg = 7'b1000000; // "0"  
         4'b0001: sevSeg = 7'b1111001; // "1" 
         4'b0010: sevSeg = 7'b0100100; // "2" 
         4'b0011: sevSeg = 7'b0110000; // "3" 
         4'b0100: sevSeg = 7'b0011001; // "4" 
         4'b0101: sevSeg = 7'b0010010; // "5" 
         4'b0110: sevSeg = 7'b0000010; // "6" 
         4'b0111: sevSeg = 7'b1111000; // "7" 
         4'b1000: sevSeg = 7'b0000000; // "8"  
         4'b1001: sevSeg = 7'b0010000; // "9" 
         4'b1010: sevSeg = 7'b0001000; // "A"
         4'b1011: sevSeg = 7'b0000011; // "b"
         4'b1100: sevSeg = 7'b1000110; // "C"
         4'b1101: sevSeg = 7'b0100001; // "d"
         4'b1110: sevSeg = 7'b0000110; // "E"
         4'b1111: sevSeg = 7'b0001110; // "F"
     endcase
     if (fourDigit == 4'b1011)
     begin
        if (dispCheckSumCheck)   // if sum is displaying or not
            sevSeg = 7'b0110111;
        else
            sevSeg = 7'b0111111;
     end
     ledD = swD; //turn swithes to leds
     ledA = swA; //turn swithes to leds
    end
        
endmodule

