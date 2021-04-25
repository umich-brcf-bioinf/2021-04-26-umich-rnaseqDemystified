## Warming Up

In this module, we will:
* cover basic materials needed
* familiarize ourselves with remote computing
* prepare for later modules

<br>
<br>
<br>
<img src="images/building-blocks.png" width="800" />
<br>
<br>
<br>

## Warm-up exercise:

1. Try logging into the AWS instance
2. run the command `fortune | cowsay | lolcat`

Optional and only for fun!
We will have time for troubleshooting at the next section.

<br>
<br>
<br>

## Local vs remote exercise:

1. Determine if you are currently viewing a remote or local shell
2. If remote, log out by using the command `exit`
3. Become familiar with the different appearance of the local shell
4. Create local folder for results
5. Log back in to the aws instance
6. Become familiar with the differences between the local and remote shell.

<details>
<summary >Click here for hints - Local vs remote exercise</summary>

1. Determine if you are in remote or local shell
2. If remote, log out

        # If remote
        exit

3. Familiarize with local shell appearance
4. Create local folder for results

        mkdir ~/workshop_rsd


</details>

<br>
<br>
<br>

## Orientation exercise

Note: We will provide additional time during this exercise to ensure that everyone is prepared to move forward.

Orientation exercise:

1. Log in (or confirm logged in) to aws instance
2. Ensure in home directory with `cd`
3. Use `cp` to copy the data from `/rsd/data/` to your home directory
4. Use `ls` to view references
5. Use `ls` to view input fastq files
6. Use `mkdir` to create a folder for our analysis

<details>
<summary >Click here for solution</summary>

1. Ensure we're logged in to remote

        ssh <username>@50.17.210.255

2. Ensure we are in home directory

        cd

3. Copy data to our home directory

        cp -r /rsd/data/ ~/

4. View our references

        ls ~/data/refs

5. View our input fastq files

        ls ~/data/reads

6. Create a folder for our analysis

        mkdir ~/analysis

</details>


<br>
<br>
<br>
<br>
<br>
<br>
<img src="images/building-blocks-checkmark.png" width="800" />
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
