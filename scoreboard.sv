`timescale 1ns/1ps

class scoreboard;

  // Mailbox for receiving transactions from the monitor
  mailbox mon2scb; 
  
  // Counters for different types of matches and transactions
  int no_transactions, perfect, nomatch, partial;
  
  // Variables for motion values
  integer motionX, motionY;

  // Constructor: Initializes the mailbox handle
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb; 
  endfunction
  
  // Main task: Processes transactions and evaluates their results
  task main;
    Transaction trans; 
    partial = 0;
    perfect = 0;
    nomatch = 0;
    $display("*---------*----------*--------* SCOREBOARD MODULE -BEGINS *--------*--------*-------*----------*");
    forever begin
      mon2scb.get(trans); // Get transaction from monitor
      $display("Expected_motionX : %d, Expected_motionY : %d", trans.expectedXMotion, trans.expectedYMotion);
      
      // Adjust motionX and motionY for signed values
      if (trans.actualXMotion >= 8)
        motionX = trans.actualXMotion - 16;
      else
        motionX = trans.actualXMotion;

      if (trans.actualYMotion >= 8)
        motionY = trans.actualYMotion - 16;
      else
        motionY = trans.actualYMotion;

      $display("\n*---------*----------*--------*--------* RESULTS *--------*--------*-------*----------*--------*");

      // Evaluate the transaction based on bestDistance value
      if (trans.bestDistance == 8'hFF) begin
        $display("Reference Memory Not Found in the Search Window!");
        nomatch++;
      end
      else begin
        if (trans.bestDistance == 8'h00) begin
          $display("Perfect Match Found for Reference Memory in the Search Window"); 
          $display(" bestDistance = %0d, motionX = %0d, motionY = %0d, expectedXMotion = %0d, expectedYMotion = %0d", 
                    trans.bestDistance, motionX, motionY, trans.expectedXMotion, trans.expectedYMotion);
          perfect++;
        end
        else begin
          $display(" Partial Match Found: bestDistance = %0d, motionX = %0d, motionY = %0d, expectedXMotion = %0d, expectedYMotion = %0d", 
                    trans.bestDistance, motionX, motionY, trans.expectedXMotion, trans.expectedYMotion);
          partial++;
        end
      end

      // Compare DUT motion values with expected values
      if (motionX == trans.expectedXMotion && motionY == trans.expectedYMotion) begin
        $display("Motion As Expected :: DUT motionX = %0d, DUT motionY = %0d, expectedXMotion = %0d, expectedYMotion = %0d", 
                  motionX, motionY, trans.expectedXMotion, trans.expectedYMotion);
      end
      else begin
        $display("Motion Not As Expected :: DUT motionX = %0d, DUT motionY = %0d, expectedXMotion = %0d, expectedYMotion = %0d", 
                  motionX, motionY, trans.expectedXMotion, trans.expectedYMotion);
      end

      $display("****************************************n");  
      no_transactions++;
      $display("Number of Transaction Packets: %d", no_transactions);
      $display("****************************************\n");
    end
  endtask

endclass
