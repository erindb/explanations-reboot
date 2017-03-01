See the [wiki](https://web.stanford.edu/group/cocolab/cgi-bin/mediawiki/index.php/Running_models_on_sherlock_server) for basic Sherlock instructions.

Here's an example sbatch file, `run_s2_grid.sbatch`:

	#!/bin/bash
	#
	#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling
	#################
	#set a job name
	#SBATCH --job-name=explanations
	#################
	#a file for job output, you can check job progress
	#SBATCH --output=explanations.out
	#################
	# a file for errors from the job
	#SBATCH --error=explanations.err
	#################
	#time you think you need; default is one hour; max is 48 hours
	#SBATCH --time=8:00:00
	#################
	#quality of service; think of it as job priority (set --qos=long to submit a job for > 2 days & < 7 days)
	#SBATCH --qos=normal
	#################
	#number of nodes you are requesting (this will usually be 1)
	#SBATCH --nodes=1
	#################
	#memory per node; default is 4000 MB per CPU
	#SBATCH --mem=4000
	#you could use --mem-per-cpu; they mean what we are calling cores
	#################
	#tasks to run per node; a "task" is usually mapped to a MPI processes.
	# for local parallelism (OpenMP or threads), use "--ntasks-per-node=1 --cpus-per-task=16" instead
	#SBATCH --ntasks-per-node=1
	################# 

	#now run normal batch csommands                                                                                 
	cd ~/explanations-reboot/models/11-flat-lk/
	echo $SLURM_ARRAY_TASK_ID
	Rscript run_model.R $SLURM_ARRAY_TASK_ID

Here's the syntax:

	sbatch --array={start}-{end}:{step} {path/to/file.sbatch}

Here's an example of some paramters, where the `$SLURM_ARRAY_TASK_ID` argument to the R script `run_s2_grid.sbatch` ranges from 1 to 144 with step-size 1:

	sbatch --array=1-144:1 ~/run_s2_grid.sbatch

This will print out a job ID that you should hang on to for later:

	Submitted batch job {jobID}

For example:

	Submitted batch job 13011986

In order to check the state of this process, we can run:

	sacct -j {jobID} -o JobID,State,Elapsed

For this example:

	sacct -j 13011986 -o JobID,State,Elapsed

While the task is pending, you will see one job:

	       JobID      State    Elapsed 
	------------ ---------- ---------- 
	13011986_[1+    PENDING   00:00:00 

Once the tasks are actually running, you'll see three rows for each argument.

To cancel all of your current running tasks:

	scancel -u {username}

In my case:

	scancel -u erindb

I wanted to see three coloumns. The default output will be sevel columns:

	sacct -j 13011986

By default, we will get these columns:

	JobID    JobName  Partition    Account  AllocCPUS      State ExitCode 

We could see all the columns by running:

	sacct -lj 13011986

Then we will see all of these columns:

    JobID     JobIDRaw    JobName  Partition  MaxVMSize  MaxVMSizeNode  MaxVMSizeTask  AveVMSize     MaxRSS MaxRSSNode MaxRSSTask     AveRSS MaxPages MaxPagesNode   MaxPagesTask   AvePages     MinCPU MinCPUNode MinCPUTask     AveCPU   NTasks  AllocCPUS    Elapsed      State ExitCode AveCPUFreq ReqCPUFreqMin ReqCPUFreqMax ReqCPUFreqGov     ReqMem ConsumedEnergy  MaxDiskRead MaxDiskReadNode MaxDiskReadTask    AveDiskRead MaxDiskWrite MaxDiskWriteNode MaxDiskWriteTask   AveDiskWrite    AllocGRES      ReqGRES    ReqTRES  AllocTRES 

