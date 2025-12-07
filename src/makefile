QUESTA := /home/share/questa.csh
SHELL := /bin/csh
 
IGNORE:
        make clean
        make view
 
.ONESHELL:
 
all:
        source $(QUESTA)
        make clean
        make compile
        make simulate
 
# ------------------------ MAIN (Coverage Flow) -----------------------
#  main:
#          source $(QUESTA)
#                  make clean
#                          vlog -sv +acc +cover +fcover testbench.sv \
#                                          "+incdir+/tools/mentor/questasim_10.6c/questasim/uvm-1.1d/../verilog_src/uvm-1.1d/src"
#                                                  vsim -vopt work.apb_slave_top -voptargs=+acc=npr \
#                                                                  -assertdebug -l simulation.log -coverage -c \
#                                                                                  -do "coverage save -onexit -assert -directive -cvg -codeAll coverage.ucdb; run -all; exit"
#                                                                                          vcover report -html coverage.ucdb -htmldir covReport -details
#                                                                                           
#                                                                                           # ------------------------ Coverage Read Only ------------------------
read:
        source $(QUESTA)
        vcover report -details coverage.ucdb
 
# ------------------------ Open HTML Coverage ------------------------
#  view:
#          firefox ./covReport/index.html
#           
#           # ------------------------ Compile Only ------------------------
compile:
        vlog -sv testbench.sv
 
# ------------------------ Simulate Only ------------------------
#  simulate:
#          vsim -c apb_slave_top +UVM_VERBOSITY=UVM_MEDIUM -do "run -all; exit"
#           
#           # ------------------------ Clean ------------------------
clean:
        rm -rf transcript work/ covReport coverage.ucdb simulation.log
        clear
        clear
