#!/bin/bash


##################################################
# Report initial configuration of the script and set variables
echo "`basename $0` started. workname is $1, DataGenerator is $2, OriginalDataGenerator is $3 "

WORKNAME=$1
DG=$2
cp $3 control.bngl
ORIGDG=control.bngl

##########################################################################################
# imporant global variables                                                              #
##########################################################################################
     # constants                                                                         #
     #####################################################################################
GENERATION=0           # our current generation, how long the simulation has been running
POOL_SIZE=${4:-20}      # how many candidates are alive at once (in this case 20)
MUTATION_RATE=${7:-75} # for each birth, the chance (0 to 100) that a mutation will occur
NUM_MUTATIONS=${8:-1}  # max number of mutations to apply to a single child
MAX_GENERATIONS=2000


BEST_VAL=0   #Ya que vamos a minimizar una diferencia, el mejor valor para mí es 0 (generalizar)

TARGET_PARAMETERS_NUMBER=${8:-7}   #Number of target parameters to get (number of genes in chromosome)


declare -a CANDIDATES           # our candidate population
declare -a TARGET_ARRAY         # used for our fitness function
declare -a CANDIDATE_ARRAY      # used for our fitness function
declare -a FITNESS              # matches the CANDIDATE_ARRAY, the fitness value of each member

echo "Pool Size: $POOL_SIZE      Best Fits: $BEST_FITS       Num Mutations: $NUM_MUTATIONS"
echo "Run for $MAX_GENERATIONS generations"
#####################################################################################
#####################################################################################
     # useful scratch variables, I am including them here for reference only...          #
     #####################################################################################
LAST_PARENT=0      # marks the end of the parents in this generation, after this are the kids
POPULATION_SCORE=0 # used to show how close the population as a whole is getting

##########################################################################################
# HELPER SCRIPTS                                                                     #
##########################################################################################

RUNR1=/home/rvv/LPH/GA_exploration/MM/generate_candidates_MM_As_0_end_Carlitos_A.R #Generates one candidate
RUNBNGL="perl /home/rvv/LPH/RuleBender/BioNetGen-2.2.0/BNG2.pl"
RUNR2=/home/rvv/LPH/GA_exploration/MM/canberra.R #Calculates canberra's distance
RUNR3=/home/rvv/LPH/GA_exploration/MM/max_min.R 
RUNR4=/home/rvv/LPH/GA_exploration/MM/CHANGE_PARAM_MM_As_0_end_Carlitos_A.R #Generates a parameter to change it for the current (i.e. mutation)
RUNR5=/home/rvv/LPH/GA_exploration/MM/recombine_blended.R #Recombinates two of the current candidates

##########################################################################################
# helper functions and calls                                                                      #
##########################################################################################
     #####################################################################################
     # gen_candidates( index ) - will return the candidates according to our particular 
     #function and the number of candidates that we determined.
     #
     #####################################################################################

run_goal() #Runs the file that gives as result the dynamics of the original system (in this case the one from CAF)
{
	$RUNBNGL $ORIGDG
}


generate_candidate() #Generates a set of candidate parameters (genome)
{
	CANDIDATE=$(Rscript $RUNR1) 
    	#CANDIDATE="lala one 1"
	echo "$CANDIDATE"
}


prepare_candidate() 
{
	cp $DG candidate.bngl
	FILE=candidate.bngl
	#echo "$FILE"
	sed -i "s/k_prod_Aa .*/k_prod_Aa $1/g" $FILE
	sed -i "s/kdegrRNA .*/kdegrRNA $2/g" $FILE
    sed -i "s/s .*/s $3/g" $FILE
    sed -i "s/kon2 .*/kon2 $4/g" $FILE
    sed -i "s/koff2 .*/koff2 $5/g" $FILE
    sed -i "s/c .*/c $6/g" $FILE
    sed -i "s/ep .*/ep $7/g" $FILE
	#echo "I prepared the candidate"
  }


run_candidate()
{
	cp $1 candidate.bngl #copy file to candidate.bngl
	$RUNBNGL $1 #Run bngl simulation of candidate
	#echo "I just ran the candidate"
  } 

objetive_fun()
{
	CANDIDATE_GDAT=$1
	Rscript $RUNR2 control.gdat $CANDIDATE_GDAT #Compare control vs candidate simulations by canberra distance
	#echo "I calculated objective function"
}

recombine()
{
a=$1
RNDM_GUY1=`echo $[ $[ RANDOM % ($POOL_SIZE-14) ]]` #Select one from the six best sons to recombine
RNDM_GUY2=`echo $[ $[ RANDOM % ($POOL_SIZE-14) ]]` #Select one from the six best sons to recombine



while [ "$RNDM_GUY1" -eq "$RNDM_GUY2" ]; do #In case you chose twice the same child...
RNDM_GUY2=`echo $[ $[ RANDOM % ($POOL_SIZE-12) ]]`
done

echo "My random child 1 is $RNDM_GUY1 and its values are ${CANDIDATES[${ORDER[$RNDM_GUY1]}]}" >> random_guys.txt #Useful for debugging
echo "My random child 2 is $RNDM_GUY2 y and its values are ${CANDIDATES[${ORDER[$RNDM_GUY2]}]}" >> random_guys.txt #Useful for debugging
printf "${CANDIDATES[${ORDER[$RNDM_GUY1]}]}\n${CANDIDATES[${ORDER[$RNDM_GUY2]}]}" > recomb_us.txt #File with the gys to recombinate

#for i in $(seq 1 $CHILDREN)
#	do
ONE=`echo $[ 1 + $[ RANDOM % ($TARGET_PARAMETERS_NUMBER-1) ]]`
TWO=`echo $[ 1 + $[ RANDOM % ($TARGET_PARAMETERS_NUMBER-1) ]]`

while [ "$ONE" -eq 1 -a "$TWO" -eq "$TARGET_PARAMETERS_NUMBER" -o "$ONE" -eq "$TARGET_PARAMETERS_NUMBER" -a "$TWO" -eq 1 ];do
TWO=`echo $[ 1 + $[ RANDOM % ($TARGET_PARAMETERS_NUMBER-1) ]]`
done

if [[ "$ONE" -le "$TWO" ]]; then
RNDM_START=$ONE #Recombination start place in the child 1
RNDM_END=$TWO #Recombination end place in the child 1
else
RNDM_START=$TWO #Recombination start place in the child 2
RNDM_END=$ONE #Recombination end place in the child 2
fi


Rscript $RUNR5 $RNDM_START $RNDM_END "recomb_us.txt"
NEW_GUY=`cat son.txt`
echo "this is new guy by recombination $NEW_GUY" >>New_guys.txt #Here are the recombination rsults
eval "$a=\$NEW_GUY"
}



mutate()
{
	a=$1 #assign the name of the new variable to "$a"
	#insides=${!a}
	RNDM_GUY=`echo $[ 3 + $[RANDOM % ($POOL_SIZE - 6) ]]` #The 6 worst have no chance to mutate
RNDM_PARAM=`echo $[ 1 + $[ RANDOM % $TARGET_PARAMETERS_NUMBER ]]` #Any of the paraeters can be the one that mutates
	Rscript $RUNR4 $RNDM_PARAM
	NEW_PAR=`cat param.txt`
	insides=${CANDIDATES[${ORDER[$RNDM_GUY]}]}
	ARR=($insides)
	let PAR=$RNDM_PARAM-1
	ARR[$PAR]=$NEW_PAR
	NEW_GUY=$( IFS=$' '; echo "${ARR[*]}" )	
	#echo "The new parameters $RNDM_PARAM  for the guy $NEW_PAR is saved in ${ARR[$RNDM_PARAM]}}"
	echo "I'm the new guy by mutation $NEW_GUY" >> New_guys.txt
	eval "$a=\$NEW_GUY" 	
}

display_prodigy()
{
   printf ">>> Im in   Generation:      $GENERATIONS"
printf "   Prodigy: > ${CANDIDATES[${ORDER[0]}]} < with a score of ${OBJETIVE[${ORDER[0]}]}\n" #Displaying best fit guy and its chromosome
}

check_guy(){ #
prepare_candidate $1 $DG
	run_candidate candidate.bngl >> MIU.TXT
	echo "whe are one $1 and two $2 " >> params_check_guy.txt
	cp candidate.gdat "candidate_$2.gdat"
	objetive_fun candidate.gdat
	OBJETIVE[$2]=`cat output.txt`
	LINE=`cat output.txt`
	echo "soy la diferencia ${OBJETIVE[$2]}"
	echo "soy la diferencia en LINE $LINE"
}
#################################################################################################

#################################################################################################
###################################EXAMPLE of WORKING FUNCTIONS ##################################
#################################################################################################
#generate_candidate >> alfa.txt
#alfa="`cat alfa.txt`"

#run_goal
#cp $DG new_cand.bngl
#prepare_candidate $alfa new_cand.bngl
#objetive_fun candidate.gdat >> diff.txt
################################################################################################


###############################################################################################
###############################################################################################
############################################G A################################################
###############################################################################################
#declare -a param_cands
################################Generate INITAL population####################################

#run the goal 
run_goal

let POOL=$POOL_SIZE-1
#Generate the first candidates
for i in $(seq 0 $POOL)
	do
		generate_candidate > cosa 
		CANDIDATES[$i]=`cat cosa`
		echo "soy el candidato $i ${CANDIDATES[$i]}" >>First_candidates.txt
		check_guy "${CANDIDATES[$i]}" "$i"
	done

echo "${OBJETIVE[*]}" > "all_diff.txt"

MIN_CAND=$(Rscript $RUNR3 all_diff.txt)

line=`cat order.txt` #Candidate order
#rm order.txt
ORDER=($line) #Candidate order in array
echo "Lo que tengo en ORDER ${ORDER[*]}" >>ORDER.txt	

cat all_diff.txt >> diferencias_todas.txt
cat order.txt >> todos_ordenados.txt
	

############################Begin cycles#################################
GENERATIONS=1


while [ $GENERATIONS -le $MAX_GENERATIONS ];do
	
	NEW_GEN[0]=${CANDIDATES[${ORDER[0]}]} #save the 7 best fit
	NEW_GEN[1]=${CANDIDATES[${ORDER[1]}]}
	NEW_GEN[2]=${CANDIDATES[${ORDER[2]}]}
	NEW_GEN[3]=${CANDIDATES[${ORDER[3]}]}
	NEW_GEN[4]=${CANDIDATES[${ORDER[4]}]}
	NEW_GEN[5]=${CANDIDATES[${ORDER[5]}]}
	NEW_GEN[6]=${CANDIDATES[${ORDER[6]}]}

new_gen_index=8 #there are already four guys for the next generation

#The nexy guys will be the offspring of these best four

for new_gen_index in $(seq 7 13)
do
recombine NEW_GEN[$new_gen_index]
echo "I am the new candidate by recombination ($new_gen_index)!! ${NEW_GEN[$new_gen_index]}" >> nuevos_cand #for further debugging, this can be commented for further economy
done

for new_gen_index in $(seq 14 $POOL)
do
generate_candidate > cosa
NEW_GEN[$new_gen_index]=`cat cosa`
echo "I am the new candidate ($new_gen_index)!! ${NEW_GEN[$new_gen_index]}" >>nuevos_cand
done

#Mutate random guy that is not one of the four best fits

for new_gen_index in $(seq 1 10)#mutation rate is 10% aprox 10 changes

do
RNDM_GUY=`echo $[ 4 + $[RANDOM % ($POOL) ]]` #I don't want to change the 4 best ones
mutate NEW_GEN[$RNDM_GUY] $RNDM_GUY
echo "I am the new mutated candidate ($RNDM_GUY)!! ${NEW_GEN[$RNDM_GUY]}" >> nuevos_cand
done


echo "All my candidates ${NEW_GEN[*]}"	>> "all_new.txt"

CANDIDATES=( "${NEW_GEN[@]}" )

echo "Todos mis candidatos en CANDIDATES ${CANDIDATES[*]}"	>> "candidates.txt"

#Checking the cost of all candidates after mutations preserving the first four

check_guy "${CANDIDATES[0]}" "0"
check_guy "${CANDIDATES[1]}" "1"
check_guy "${CANDIDATES[2]}" "2"
check_guy "${CANDIDATES[3]}" "3"

for i in $(seq 4 $POOL)
do
echo "soy el candidato $i ${CANDIDATES[$i]} de la generación $GENERATIONS " >> candidates.txt
check_guy "${CANDIDATES[$i]}" "$i"
done

echo "${OBJETIVE[*]}" > "all_diff.txt"

MIN_CAND=$(Rscript $RUNR3 all_diff.txt)

line=`cat order.txt` #Candidate order



ORDER=($line) #Candidate order in array
echo "Lo que tengo en ORDER ${ORDER[*]}" >>ORDER.txt


cat all_diff.txt >> diferencias_todas.txt #All the differences
cat order.txt >> todos_ordenados.txt #All ordered



for j in $(seq 0 $POOL)
do
echo "My differenc is ${OBJETIVE[${ORDER[$j]}]} and I am the candidate ${ORDER[$j]} in oreder of the generation ($GENERATIONS) ${CANDIDATES[${ORDER[$j]}]} and my unordered index is $j" >> ordenamiento.txt # Every single candidate with its characteristics across all generations (probably the most valuable output)
done

display_prodigy >> "Results.txt" #Best child from generation with its parameters
let GENERATIONS=$GENERATIONS+1 #Change generation

done
