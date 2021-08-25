#!/bin/bash
#SBATCH --job-name=testScripts
#SBATCH --output=testScripts.log
#SBATCH --mail-user=YOUR_EMAIL
#SBATCH --mail-type=FAIL,END
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=1000M
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=common
#SBATCH --account=bio790s-01-f21
[[ -d $SLURM_SUBMIT_DIR ]] && cd $SLURM_SUBMIT_DIR

perl getResults.pl
python3 getResults.py