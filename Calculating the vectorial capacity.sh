#!/bin/bash

#cal VC using monthly temperature (Tn, Tm, Tx) with rainfall factor.
# Other parameters such EIP and surp will also be calculated on grid level
#========================================================================
path1=~/Research/Malaria/Vectorialcapacity/data

a=0.5
b=0.5
c=0.5
m=4.0

echo $c > tta

k=`awk -v a=$a -v b=$b -v m=$m '{printf("%6.4f\n",$1*a*a*b*m)}' tta`
rm tta

#Multiply the k value with rainfall
######################################

input2=${path1}/Ghana_CHIRPS_dRR_1981_2020.nc

cdo mulc,$k $input2 kRR.nc


for dt in Tm # Tm Tx 
do
    
    output1=${path1}/clim_EIP_${dt}.nc
    output2=${path1}/clim_survp_${dt}.nc
    output3=${path1}/clim_vc_RR_${dt}.nc
    
    if [ -s $output1 ] || [ -s $output2 ] || [ -s $output3 ] ; then
	rm $output1 ; rm $output2; rm $output3
    fi

    input1=${path1}/Ghana_ERA5_d${dt}_1981_2020.nc
    
     
     # Regrid the temperature data to match that of rainfall
     #using: cdo  remapbil,targetgrid -setgrid,sourcegrid  ifile  ofile
     ######################################################

     cdo griddes $input2 > targetgrid.txt
     cdo griddes $input1 > sourcegrid.txt

     #regrid with near neighbour method
     cdo remapnn,targetgrid.txt -setgrid,sourcegrid.txt $input1 out.nc
     rm targetgrid.txt ; rm sourcegrid.txt 
 
       ######## Renaming a variable  #####
     #$ cdo chname,SST,new_sst yi_sst.nc yi_sst_2.nc
    
  #1 cal the EIP=111/(T-16)
     #############################
     
     cdo expr,'eip=111/(mean2t-16)' out.nc dEIP.nc
     cdo ymonmean -monmean dEIP.nc $output1 
    # rm dEIP.nc

    #2 cal survival probability. p=−0.00082T^2 + 0.0367T+ 0.522
    ##########################################################
     
  cdo expr,'survp=(-0.00082*mean2t*mean2t) + (0.0367*mean2t) + 0.522' out.nc dsurvp.nc
  cdo ymonmean -monmean dsurvp.nc $output2
  #  rm dsurvp.nc

    

    #3 cal vectorial capacity: (kRR.nc*p^EIP)/-ln(p)
    ############################################
  # take ln of the survp
  cdo mulc,-1 -ln dsurvp.nc tta.nc
  
  
  #we merge the EIP and surv and find their power
  cdo merge dEIP.nc dsurvp.nc  tta1.nc
  rm dEIP.nc; rm dsurvp.nc
  
  cdo expr,'peip=survp^eip' tta1.nc tta2.nc
  rm tta1.nc
  
  #multiply by kRR.nc but first merge the two files

  cdo merge kRR.nc tta2.nc tat1.nc
  rm kRR.nc ; rm tta2.nc 
  
  cdo expr,'peipRR=peip*precip' tat1.nc tat2.nc
  rm tat1.nc

  
  cdo merge tta.nc tat2.nc tta3.nc
  rm tta.nc ; rm tat2.nc
  
  cdo expr,'vc=peipRR/survp ' tta3.nc tta1.nc
  rm tta3.nc

  cdo ymonmean -monmean tta1.nc $output3
  rm tta1.nc
  rm out.nc
done
exit


